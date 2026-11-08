"""Everything Waqt says about the Sunnah, sourced from HadeethEnc.com.

    python tool/build_content.py

HadeethEnc.com (Encyclopedia of Translated Prophetic Hadiths, by the team
behind QuranEnc and IslamHouse) publishes authentic hadiths with reviewed
translations and explanations in 70+ languages, one SQLite file per
language. Its terms: no changes to the content, credit HadeethEnc.com with
the version, keep it updated, report errors to them.

This script
  - downloads the HadeethEnc file for each app language (cached),
  - checks every hadith Waqt points to: it exists, it is not graded weak,
    and for dhikr, the Arabic words appear in that hadith's Arabic,
  - writes assets/sources/days.json      (day and moment checklists),
            assets/sources/hadeethenc.json (those hadiths, every language,
                                            bundled so Home works offline),
            lib/features/counter/dhikr_data.dart.

The checklist labels and dhikr lines below are short app labels we write,
in each app language; the hadith they open is HadeethEnc's, unchanged. In a
language HadeethEnc has not translated a hadith into yet, the app shows its
Arabic, never another language.
"""

import datetime
import io
import json
import os
import re
import sqlite3
import sys
import tempfile
import urllib.request
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LANGS = ["en", "ar", "ur", "bn", "id", "tr", "fr"]
URL = "https://hadeethenc.com/downloads/sqlite/{}.sqlite.zip"
CACHE = os.path.join(tempfile.gettempdir(), "waqt-hadeethenc-sqlite")
WEAK = ("ضعيف", "موضوع", "منكر")

# Labels: key -> (en, ar, ur, bn, id, tr, fr)
L = {
    "dates": ("Eat an odd number of dates before the prayer", "كُل تمرات وترًا قبل الصلاة", "نماز سے پہلے طاق عدد میں کھجوریں کھائیں", "নামাজের আগে বেজোড় সংখ্যক খেজুর খান", "Makan kurma berjumlah ganjil sebelum salat", "Namazdan önce tek sayıda hurma ye", "Mangez un nombre impair de dattes avant la prière"),
    "zakat": ("Pay Zakat al-Fitr before the prayer", "أخرج زكاة الفطر قبل الصلاة", "نماز سے پہلے صدقۂ فطر ادا کریں", "নামাজের আগে ফিতরা আদায় করুন", "Tunaikan zakat fitrah sebelum salat", "Fıtır sadakasını namazdan önce ver", "Versez la zakat al-fitr avant la prière"),
    "goout": ("Everyone goes out to the prayer, saying the takbir", "اخرجوا جميعًا إلى المصلى مكبّرين", "سب عیدگاہ جائیں اور تکبیر کہیں", "সবাই তাকবির বলতে বলতে ঈদগাহে যান", "Semua keluar ke tempat salat sambil bertakbir", "Herkes tekbir getirerek namaza çıksın", "Tous sortent vers la prière en disant le takbir"),
    "way": ("Return home by a different way", "ارجع من طريق آخر", "واپسی دوسرے راستے سے کریں", "অন্য পথে বাড়ি ফিরুন", "Pulang lewat jalan yang berbeda", "Eve başka yoldan dön", "Rentrez par un autre chemin"),
    "nofast": ("Do not fast today", "لا تصم اليوم", "آج روزہ نہ رکھیں", "আজ রোজা রাখবেন না", "Jangan berpuasa hari ini", "Bugün oruç tutma", "Ne jeûnez pas aujourd'hui"),
    "shawwal": ("Then fast six days of Shawwal", "ثم صم ستًا من شوال", "پھر شوال کے چھ روزے رکھیں", "এরপর শাওয়ালের ছয়টি রোজা রাখুন", "Lalu puasa enam hari di bulan Syawal", "Sonra Şevval'den altı gün oruç tut", "Puis jeûnez six jours de Chawwal"),
    "eatafter": ("Eat nothing until after the prayer", "لا تأكل حتى تصلي", "نماز کے بعد تک کچھ نہ کھائیں", "নামাজের পর পর্যন্ত কিছু খাবেন না", "Jangan makan sampai selesai salat", "Namazdan sonraya kadar bir şey yeme", "Ne mangez rien avant la prière"),
    "sacrifice": ("Offer the sacrifice after the prayer", "اذبح أضحيتك بعد الصلاة", "قربانی نماز کے بعد کریں", "নামাজের পর কুরবানি করুন", "Sembelih kurban setelah salat", "Kurbanı namazdan sonra kes", "Sacrifiez après la prière"),
    "bestdays": ("No days are better for good deeds", "لا أيام العمل الصالح فيها أحب إلى الله", "نیک عمل کے لیے ان سے بہتر کوئی دن نہیں", "নেক আমলের জন্য এর চেয়ে উত্তম দিন নেই", "Tidak ada hari yang lebih utama untuk beramal saleh", "Salih amel için bundan daha üstün gün yok", "Aucun jour n'est meilleur pour les bonnes œuvres"),
    "hairnails": ("If you will sacrifice, leave your hair and nails", "من أراد أن يضحي فلا يأخذ من شعره وأظفاره", "قربانی کا ارادہ ہو تو بال اور ناخن نہ کاٹیں", "কুরবানি দিলে চুল ও নখ কাটবেন না", "Jika akan berkurban, jangan potong rambut dan kuku", "Kurban kesecekseniz saç ve tırnağınızı kesmeyin", "Si vous sacrifiez, ne coupez ni cheveux ni ongles"),
    "arafahfast": ("Fast the Day of Arafah", "صم يوم عرفة", "یومِ عرفہ کا روزہ رکھیں", "আরাফার দিনের রোজা রাখুন", "Puasa hari Arafah", "Arefe günü oruç tut", "Jeûnez le jour d'Arafat"),
    "arafahfire": ("No day frees more people from the Fire", "ما من يوم أكثر عتقًا من النار", "اس دن سب سے زیادہ لوگ جہنم سے آزاد ہوتے ہیں", "এই দিনে সবচেয়ে বেশি মানুষ জাহান্নাম থেকে মুক্তি পায়", "Hari paling banyak hamba dibebaskan dari neraka", "Cehennemden en çok kişinin azat edildiği gün", "Le jour où le plus de gens sont affranchis du Feu"),
    "tashreqeat": ("Days of eating, drinking and remembering Allah", "أيام أكل وشرب وذكر لله", "کھانے پینے اور اللہ کے ذکر کے دن", "খাওয়া, পান করা ও আল্লাহর জিকিরের দিন", "Hari makan, minum, dan zikir kepada Allah", "Yeme, içme ve Allah'ı anma günleri", "Jours où l'on mange, boit et invoque Allah"),
    "tashreqfast": ("Do not fast on these days", "لا تصم هذه الأيام", "ان دنوں روزہ نہ رکھیں", "এই দিনগুলোতে রোজা রাখবেন না", "Jangan berpuasa pada hari-hari ini", "Bu günlerde oruç tutma", "Ne jeûnez pas ces jours-là"),
    "ninth": ("Fast the ninth along with Ashura", "صم التاسع مع عاشوراء", "عاشورہ کے ساتھ نویں کا روزہ بھی رکھیں", "আশুরার সাথে নবম তারিখেও রোজা রাখুন", "Puasa tanggal sembilan bersama Asyura", "Aşure ile birlikte dokuzuncu günü de oruç tut", "Jeûnez le neuvième avec Achoura"),
    "muharram": ("The best fasting after Ramadan is in Muharram", "أفضل الصيام بعد رمضان شهر الله المحرم", "رمضان کے بعد بہترین روزے محرم کے ہیں", "রমজানের পর সর্বোত্তম রোজা মুহাররমের", "Puasa terbaik setelah Ramadan adalah di bulan Muharram", "Ramazan'dan sonra en faziletli oruç Muharrem'dedir", "Le meilleur jeûne après Ramadan est en Mouharram"),
    "ashurafast": ("Fast the Day of Ashura", "صم يوم عاشوراء", "عاشورہ کا روزہ رکھیں", "আশুরার রোজা রাখুন", "Puasa hari Asyura", "Aşure günü oruç tut", "Jeûnez le jour d'Achoura"),
    "ashurawhy": ("Why the Prophet ﷺ fasted Ashura", "لماذا صام النبي ﷺ عاشوراء", "نبی ﷺ نے عاشورہ کا روزہ کیوں رکھا", "নবী ﷺ কেন আশুরার রোজা রাখতেন", "Mengapa Nabi ﷺ berpuasa Asyura", "Peygamber ﷺ Aşure orucunu neden tuttu", "Pourquoi le Prophète ﷺ jeûnait Achoura"),
    "suhoor": ("Eat suhoor, there is blessing in it", "تسحّر فإن في السحور بركة", "سحری کریں، اس میں برکت ہے", "সাহরি খান, এতে বরকত আছে", "Makan sahur, di dalamnya ada berkah", "Sahura kalk, onda bereket var", "Prenez le souhour, il contient une bénédiction"),
    "latesuhoor": ("Take suhoor late, close to Fajr", "أخّر السحور قرب الفجر", "سحری فجر کے قریب کریں", "ফজরের কাছাকাছি সময়ে সাহরি খান", "Akhirkan sahur mendekati Subuh", "Sahuru imsaka yakın yap", "Retardez le souhour, près de l'aube"),
    "faith": ("Fast with faith, hoping for reward", "صم إيمانًا واحتسابًا", "ایمان اور ثواب کی امید سے روزہ رکھیں", "ঈমান ও সওয়াবের আশায় রোজা রাখুন", "Berpuasa karena iman dan mengharap pahala", "İnanarak ve sevabını umarak oruç tut", "Jeûnez avec foi, en espérant la récompense"),
    "tongue": ("Guard your tongue and your actions", "احفظ لسانك وعملك", "اپنی زبان اور عمل کی حفاظت کریں", "জিহ্বা ও কাজকে সংযত রাখুন", "Jaga lisan dan perbuatan", "Dilini ve davranışlarını koru", "Gardez votre langue et vos actes"),
    "hasten": ("Break the fast as soon as the sun sets", "عجّل الفطر", "سورج ڈوبتے ہی افطار کریں", "সূর্য ডোবার সাথে সাথে ইফতার করুন", "Segerakan berbuka", "Güneş batınca hemen iftar et", "Rompez le jeûne dès le coucher du soleil"),
    "datesiftar": ("Break it with dates, or else water", "أفطر على رطب أو تمر أو ماء", "کھجور سے افطار کریں، ورنہ پانی سے", "খেজুর দিয়ে ইফতার করুন, না থাকলে পানি দিয়ে", "Berbuka dengan kurma, atau air", "Hurma ile, yoksa su ile iftar et", "Rompez-le avec des dattes, sinon de l'eau"),
    "iftardua": ("Say the dua of iftar", "قل دعاء الإفطار", "افطار کی دعا پڑھیں", "ইফতারের দোয়া পড়ুন", "Baca doa berbuka", "İftar duasını oku", "Dites l'invocation de la rupture du jeûne"),
    "feed": ("Feed someone who is fasting", "فطّر صائمًا", "کسی روزہ دار کو افطار کرائیں", "রোজাদারকে ইফতার করান", "Beri makan orang yang berpuasa", "Oruçluya iftar ettir", "Nourrissez quelqu'un qui jeûne"),
    "night": ("Pray at night in Ramadan", "قم ليل رمضان", "رمضان کی راتوں میں قیام کریں", "রমজানের রাতে নামাজে দাঁড়ান", "Salat malam di bulan Ramadan", "Ramazan gecelerini namazla ihya et", "Priez la nuit pendant Ramadan"),
    "quran": ("Read the Qur'an and give generously", "اقرأ القرآن وأكثر من الجود", "قرآن پڑھیں اور دل کھول کر خرچ کریں", "কুরআন পড়ুন ও বেশি বেশি দান করুন", "Baca Al-Qur'an dan perbanyak sedekah", "Kur'an oku ve cömertçe infak et", "Lisez le Coran et donnez généreusement"),
    "strive": ("Strive in worship and wake your family", "اجتهد في العبادة وأيقظ أهلك", "عبادت میں محنت کریں اور گھر والوں کو جگائیں", "বেশি বেশি ইবাদত করুন, পরিবারকে জাগান", "Bersungguh-sungguh beribadah dan bangunkan keluarga", "İbadette gayret et, aileni uyandır", "Redoublez d'adoration et réveillez votre famille"),
    "odd": ("Seek Laylat al-Qadr in the odd nights", "تحرّ ليلة القدر في الوتر", "لیلۃ القدر طاق راتوں میں تلاش کریں", "বেজোড় রাতে লাইলাতুল কদর খুঁজুন", "Carilah Lailatul Qadar di malam ganjil", "Kadir Gecesi'ni tek gecelerde ara", "Cherchez Laylat al-Qadr dans les nuits impaires"),
    "qadrstand": ("Stand in prayer on Laylat al-Qadr", "قم ليلة القدر", "لیلۃ القدر میں قیام کریں", "লাইলাতুল কদরে নামাজে দাঁড়ান", "Salat malam di Lailatul Qadar", "Kadir Gecesi'ni namazla geçir", "Priez durant Laylat al-Qadr"),
    "qadrdua": ("Say the dua of Laylat al-Qadr", "قل دعاء ليلة القدر", "لیلۃ القدر کی دعا پڑھیں", "লাইলাতুল কদরের দোয়া পড়ুন", "Baca doa Lailatul Qadar", "Kadir Gecesi duasını oku", "Dites l'invocation de Laylat al-Qadr"),
    "itikaf": ("I'tikaf in the last ten days", "الاعتكاف في العشر الأواخر", "آخری عشرے میں اعتکاف", "শেষ দশকে ইতিকাফ", "Iktikaf di sepuluh hari terakhir", "Son on günde itikâf", "La retraite (i'tikaf) des dix derniers jours"),
    "bid": ("Fast the 13th, 14th and 15th", "صم الثالث عشر والرابع عشر والخامس عشر", "تیرہ، چودہ اور پندرہ تاریخ کا روزہ رکھیں", "১৩, ১৪ ও ১৫ তারিখে রোজা রাখুন", "Puasa tanggal 13, 14, dan 15", "Ayın 13, 14 ve 15'inde oruç tut", "Jeûnez les 13, 14 et 15"),
    "presented": ("Deeds are presented on Monday and Thursday", "تُعرض الأعمال يوم الاثنين والخميس", "پیر اور جمعرات کو اعمال پیش ہوتے ہیں", "সোম ও বৃহস্পতিবার আমল পেশ করা হয়", "Amal diperlihatkan pada Senin dan Kamis", "Ameller pazartesi ve perşembe sunulur", "Les œuvres sont présentées le lundi et le jeudi"),
    "monthu": ("The Prophet ﷺ made a point of fasting them", "كان النبي ﷺ يتحرى صيامهما", "نبی ﷺ ان دنوں کے روزے کا اہتمام کرتے تھے", "নবী ﷺ এই দুই দিনে রোজা রাখতে যত্নবান ছিলেন", "Nabi ﷺ bersungguh-sungguh puasa di hari itu", "Peygamber ﷺ bu günlerde oruca özen gösterirdi", "Le Prophète ﷺ tenait à jeûner ces jours"),
    "bestday": ("The best day the sun rises on", "خير يوم طلعت عليه الشمس", "سب سے بہتر دن جس پر سورج طلوع ہوا", "সূর্য ওঠা দিনগুলোর মধ্যে সেরা দিন", "Hari terbaik yang disinari matahari", "Güneşin doğduğu en hayırlı gün", "Le meilleur jour sur lequel le soleil se lève"),
    "bathe": ("Bathe, go early and listen", "اغتسل وبكّر واستمع", "غسل کریں، جلدی جائیں اور خطبہ سنیں", "গোসল করুন, আগে যান ও খুতবা শুনুন", "Mandi, berangkat awal, dan dengarkan", "Gusül al, erken git ve dinle", "Lavez-vous, allez tôt et écoutez"),
    "salawat": ("Send blessings on the Prophet ﷺ", "صلِّ على النبي ﷺ", "نبی ﷺ پر درود بھیجیں", "নবী ﷺ-এর ওপর দরুদ পড়ুন", "Bershalawat kepada Nabi ﷺ", "Peygamber'e ﷺ salavat getir", "Priez sur le Prophète ﷺ"),
    "duhacharity": ("Pray Duha: charity for every joint", "صلِّ الضحى: صدقة عن كل مفصل", "چاشت پڑھیں: ہر جوڑ کا صدقہ", "চাশতের নামাজ পড়ুন: প্রতিটি জোড়ার সদকা", "Salat Duha: sedekah untuk setiap sendi", "Kuşluk namazı kıl: her eklemin sadakası", "Priez Ad-Douha : une aumône pour chaque articulation"),
    "duhahot": ("Best when the sun is high and hot", "أفضلها حين يشتد الحر", "جب دھوپ تیز ہو تب افضل ہے", "রোদ তীব্র হলে পড়া উত্তম", "Paling utama saat matahari terik", "En faziletlisi güneş iyice yükselince", "Meilleure quand le soleil est haut et chaud"),
    "duhatwo": ("Two rak'ahs of Duha, as the Prophet ﷺ advised", "ركعتا الضحى كما أوصى النبي ﷺ", "نبی ﷺ کی وصیت کے مطابق چاشت کی دو رکعتیں", "নবী ﷺ-এর উপদেশমতো চাশতের দুই রাকাত", "Dua rakaat Duha, sesuai wasiat Nabi ﷺ", "Peygamber'in ﷺ tavsiyesiyle iki rekât kuşluk", "Deux rak'as de Douha, comme l'a conseillé le Prophète ﷺ"),
    "descends": ("Allah descends: call on Him, ask, seek forgiveness", "ينزل ربنا: ادعه واسأله واستغفره", "اللہ نزول فرماتا ہے: دعا کریں، مانگیں، استغفار کریں", "আল্লাহ নেমে আসেন: ডাকুন, চান, ক্ষমা চান", "Allah turun: berdoalah, memintalah, mohon ampun", "Allah iner: dua et, iste, bağışlanma dile", "Allah descend : invoquez-Le, demandez, implorez Son pardon"),
    "hour": ("An hour in which dua is answered", "ساعة يستجاب فيها الدعاء", "ایک گھڑی جس میں دعا قبول ہوتی ہے", "এমন একটি মুহূর্ত, যখন দোয়া কবুল হয়", "Saat doa dikabulkan", "Duaların kabul edildiği bir an", "Une heure où l'invocation est exaucée"),
    "hourlast": ("Seek it in the last hour after Asr", "التمسوها آخر ساعة بعد العصر", "اسے عصر کے بعد آخری گھڑی میں تلاش کریں", "আসরের পর শেষ সময়ে তা খুঁজুন", "Carilah di akhir waktu setelah Asar", "Onu ikindiden sonraki son saatte ara", "Cherchez-la à la dernière heure après Asr"),
    "forgive3": ("Seek forgiveness three times", "استغفر ثلاثًا", "تین بار استغفار کریں", "তিনবার ইস্তিগফার করুন", "Istigfar tiga kali", "Üç kez istiğfar et", "Demandez pardon trois fois"),
    "tasbih33": ("SubhanAllah, Alhamdulillah, Allahu Akbar, 33 each", "سبحان الله والحمد لله والله أكبر ثلاثًا وثلاثين", "سبحان اللہ، الحمد للہ، اللہ اکبر، ہر ایک ۳۳ بار", "সুবহানাল্লাহ, আলহামদুলিল্লাহ, আল্লাহু আকবার ৩৩ বার করে", "Subhanallah, Alhamdulillah, Allahu Akbar, masing-masing 33", "Sübhanallah, Elhamdülillah, Allahu Ekber, 33'er kez", "SubhanAllah, Alhamdoulillah, Allahou Akbar, 33 fois chacun"),
    "noturned": ("Dua now is not turned back", "الدعاء لا يُرد بين الأذان والإقامة", "اذان و اقامت کے درمیان دعا رد نہیں ہوتی", "আজান ও ইকামতের মাঝে দোয়া ফিরিয়ে দেওয়া হয় না", "Doa di antara azan dan iqamah tidak ditolak", "Ezanla kamet arasındaki dua geri çevrilmez", "L'invocation entre l'appel et l'iqama n'est pas rejetée"),
    "repeat": ("Repeat the adhan, then send blessings", "ردّد الأذان ثم صلِّ على النبي ﷺ", "اذان کا جواب دیں، پھر درود پڑھیں", "আজানের জবাব দিন, তারপর দরুদ পড়ুন", "Jawab azan, lalu bershalawat", "Ezanı tekrarla, sonra salavat getir", "Répétez l'appel, puis priez sur le Prophète ﷺ"),
    "afteradhan": ("The dua after the adhan", "الدعاء بعد الأذان", "اذان کے بعد کی دعا", "আজানের পরের দোয়া", "Doa setelah azan", "Ezandan sonraki dua", "L'invocation après l'appel"),
    "wudusleep": ("Wudu, and lie on your right side", "توضأ ونم على شقك الأيمن", "وضو کریں اور دائیں کروٹ لیٹیں", "অজু করুন ও ডান কাতে শুয়ে পড়ুন", "Berwudu dan berbaring ke sisi kanan", "Abdest al ve sağ tarafına yat", "Faites les ablutions et couchez-vous sur le côté droit"),
    "dustbed": ("Dust off the bed, then say the dua", "انفض فراشك ثم قل الدعاء", "بستر جھاڑیں، پھر دعا پڑھیں", "বিছানা ঝেড়ে নিন, তারপর দোয়া পড়ুন", "Kibaskan kasur, lalu baca doa", "Yatağını silkele, sonra duayı oku", "Époussetez le lit, puis dites l'invocation"),
    "quls": ("The three Quls, then wipe over the body", "المعوذات ثم امسح جسدك", "تینوں قل پڑھ کر جسم پر ہاتھ پھیریں", "তিন কুল পড়ে শরীরে হাত বুলান", "Tiga surah Qul, lalu usap tubuh", "Üç Kul suresini oku, sonra vücudunu meshet", "Les trois Qoul, puis passez les mains sur le corps"),
    "fatima": ("Tasbih of Fatimah (RA): 33, 33, 34", "تسبيح فاطمة رضي الله عنها: ٣٣، ٣٣، ٣٤", "تسبیحِ فاطمہ رضی اللہ عنہا: ۳۳، ۳۳، ۳۴", "ফাতিমা (রা.)-এর তাসবিহ: ৩৩, ৩৩, ৩৪", "Tasbih Fatimah r.a.: 33, 33, 34", "Hz. Fatıma tesbihi: 33, 33, 34", "Le tasbih de Fatima (qu'Allah l'agrée) : 33, 33, 34"),
    "master": ("The master supplication for forgiveness", "سيد الاستغفار", "سید الاستغفار", "সাইয়্যিদুল ইস্তিগফার", "Sayyidul istighfar", "Seyyidü'l-istiğfar", "La meilleure demande de pardon"),
    "bismillah3": ("Bismillahilladhi la yadurru, three times", "بسم الله الذي لا يضر... ثلاثًا", "بسم اللہ الذی لا یضر... تین بار", "বিসমিল্লাহিল্লাযী লা ইয়াদুররু... তিনবার", "Bismillahilladzi la yadhurru, tiga kali", "Bismillahillezî lâ yedurru, üç kez", "Bismillahi-lladhi la yadourrou, trois fois"),
    "swb100": ("SubhanAllah wa bihamdihi, a hundred times", "سبحان الله وبحمده مئة مرة", "سبحان اللہ وبحمدہ سو بار", "সুবহানাল্লাহি ওয়া বিহামদিহি একশ বার", "Subhanallah wa bihamdihi seratus kali", "Sübhanallahi ve bihamdihi, yüz kez", "SubhanAllah wa bihamdihi, cent fois"),
    "noprayer": ("No voluntary prayer at these times", "لا صلاة في هذه الأوقات", "ان اوقات میں نفل نماز نہیں", "এই সময়গুলোতে নফল নামাজ নেই", "Tidak ada salat sunah di waktu ini", "Bu vakitlerde nafile namaz yok", "Pas de prière surérogatoire à ces moments"),
    "afterfajrasr": ("None after Fajr until sunrise, or after Asr until sunset", "لا صلاة بعد الفجر حتى تطلع الشمس ولا بعد العصر حتى تغرب", "فجر کے بعد طلوع تک اور عصر کے بعد غروب تک نہیں", "ফজরের পর সূর্যোদয় পর্যন্ত ও আসরের পর সূর্যাস্ত পর্যন্ত নয়", "Tidak setelah Subuh hingga terbit, dan setelah Asar hingga terbenam", "Sabahtan güneş doğana, ikindiden güneş batana kadar yok", "Rien après Fajr jusqu'au lever, ni après Asr jusqu'au coucher"),
}

# occasion id -> (label key, HadeethEnc id, when)
DAYS = {
    "eidAlFitr": [("dates", 65481, "morning"), ("zakat", 4520, "morning"), ("goout", 7200, "morning"),
                  ("way", 65484, "morning"), ("nofast", 4527, None), ("shawwal", 65523, None)],
    "eidAlAdha": [("eatafter", 65482, "morning"), ("sacrifice", 5401, None), ("goout", 7200, "morning"),
                  ("way", 65484, "morning"), ("nofast", 4527, None)],
    "firstTenDhulHijjah": [("bestdays", 6255, None), ("hairnails", 8954, None)],
    "arafah": [("arafahfast", 65874, None), ("arafahfire", 8288, None), ("bestdays", 6255, None)],
    "tashreeq": [("tashreqeat", 65519, None), ("tashreqfast", 65518, None)],
    "tasua": [("ninth", 65522, None), ("muharram", 11261, None)],
    "ashura": [("ashurafast", 10121, None), ("ashurawhy", 66404, None), ("muharram", 11261, None)],
    "ramadan": [("suhoor", 4498, "suhoor"), ("latesuhoor", 4457, "suhoor"), ("faith", 4196, "day"),
                ("tongue", 66270, "day"), ("hasten", 4438, "iftar"), ("datesiftar", 6185, "iftar"),
                ("iftardua", 65511, "iftar"), ("feed", 6271, "iftar"), ("night", 65512, "night"),
                ("quran", 6179, "day")],
    "lastTenNights": [("strive", 4944, "night"), ("odd", 4540, "night"), ("qadrstand", 4202, "night"),
                      ("qadrdua", "qadrDua", "night"), ("itikaf", 4495, "day")],
    "ayyamAlBid": [("bid", 10108, None)],
    "mondayFast": [("presented", 5908, None), ("monthu", 6183, None)],
    "thursdayFast": [("presented", 5908, None), ("monthu", 6183, None)],
    "jumuah": [("bestday", 3711, None), ("bathe", 5393, None)],
}

MOMENTS = {
    "duha": [("duhacharity", 4568), ("duhahot", 11283), ("duhatwo", 4538)],
    "lastThird": [("descends", 10412)],
    "fridayLastHour": [("hour", 65753), ("hourlast", 65755), ("salawat", 65928)],
    "afterSalah": [("forgive3", 10947), ("tasbih33", 10948)],
    "betweenAdhanIqamah": [("noturned", 5479), ("repeat", 65087), ("afteradhan", 10635)],
    "bedtime": [("wudusleep", 65911), ("dustbed", 6034), ("quls", 65060), ("fatima", 6076)],
    "jumuah": [("bathe", 5393), ("salawat", 65928), ("bestday", 3711)],
    "morningAdhkar": [("master", 5503), ("bismillah3", 6093), ("swb100", 5516)],
    "eveningAdhkar": [("master", 5503), ("bismillah3", 6093), ("swb100", 5516)],
    "restrictedSunrise": [("noprayer", 10604), ("afterfajrasr", 3081)],
    "restrictedZawal": [("noprayer", 10604)],
    "restrictedSunset": [("noprayer", 10604), ("afterfajrasr", 3081)],
    "suhoor": [("suhoor", 4498), ("latesuhoor", 4457)],
    "iftar": [("hasten", 4438), ("datesiftar", 6185), ("iftardua", 65511)],
    "taraweeh": [("night", 65512), ("quran", 6179)],
    "laylatAlQadr": [("qadrstand", 4202), ("qadrdua", "qadrDua"), ("strive", 4944), ("odd", 4540)],
}

FASTS = ["arafah", "ashura", "tasua", "ayyamAlBid", "mondayFast", "thursdayFast"]

# Dhikr: (id, arabic, latin, target, HadeethEnc id, virtue per language)
V = {
    "subhanallah": ("Said 100 times: a thousand good deeds", "مئة تسبيحة: ألف حسنة", "سو بار: ہزار نیکیاں", "১০০ বার: এক হাজার নেকি", "100 kali: seribu kebaikan", "100 kez: bin sevap", "100 fois : mille bonnes actions"),
    "alhamdulillah": ("Fills the scale", "تملأ الميزان", "میزان کو بھر دیتا ہے", "মিজানের পাল্লা ভরে দেয়", "Memenuhi timbangan", "Mizanı doldurur", "Remplit la balance"),
    "allahuakbar": ("Among the four phrases dearest to Allah", "من أحب الكلام إلى الله", "اللہ کو سب سے محبوب چار کلمات میں سے", "আল্লাহর কাছে সবচেয়ে প্রিয় চার বাক্যের একটি", "Termasuk empat kalimat yang paling dicintai Allah", "Allah'a en sevimli dört sözden biri", "Parmi les quatre paroles les plus aimées d'Allah"),
    "subhanallah_wabihamdihi": ("100 times a day: sins forgiven, even like sea foam", "مئة مرة: حُطّت خطاياه ولو كانت مثل زبد البحر", "دن میں سو بار: گناہ معاف، چاہے سمندر کی جھاگ جتنے ہوں", "দিনে ১০০ বার: গুনাহ মাফ, সমুদ্রের ফেনার সমান হলেও", "100 kali sehari: dosa diampuni walau sebanyak buih laut", "Günde 100 kez: deniz köpüğü kadar olsa da günahlar silinir", "100 fois par jour : péchés effacés, fussent-ils l'écume de la mer"),
    "two_words": ("Light on the tongue, heavy on the scale", "خفيفتان على اللسان، ثقيلتان في الميزان", "زبان پر ہلکے، میزان میں بھاری", "জিহ্বায় হালকা, মিজানে ভারী", "Ringan di lisan, berat di timbangan", "Dile hafif, mizanda ağır", "Légères sur la langue, lourdes dans la balance"),
    "four_words": ("The words most beloved to Allah", "أحب الكلام إلى الله", "اللہ کو سب سے محبوب کلمات", "আল্লাহর কাছে সবচেয়ে প্রিয় বাক্য", "Kalimat yang paling dicintai Allah", "Allah'a en sevimli sözler", "Les paroles les plus aimées d'Allah"),
    "tahlil": ("The best remembrance", "أفضل الذكر", "بہترین ذکر", "সর্বোত্তম জিকির", "Zikir yang paling utama", "Zikrin en faziletlisi", "Le meilleur rappel"),
    "tahlil_full": ("100 times a day: like freeing ten slaves, a shield from Shaytan", "مئة مرة: كعدل عشر رقاب وحرز من الشيطان", "دن میں سو بار: دس غلام آزاد کرنے کے برابر، شیطان سے حفاظت", "দিনে ১০০ বার: দশটি দাস মুক্তির সমান, শয়তান থেকে সুরক্ষা", "100 kali sehari: seperti membebaskan sepuluh budak, perisai dari setan", "Günde 100 kez: on köle azat etmek gibi, şeytana karşı kalkan", "100 fois par jour : comme affranchir dix esclaves, une protection contre Satan"),
    "istighfar": ("The Prophet ﷺ said it more than seventy times a day", "كان النبي ﷺ يقولها أكثر من سبعين مرة", "نبی ﷺ دن میں ستر سے زیادہ بار کہتے", "নবী ﷺ দিনে সত্তরবারের বেশি বলতেন", "Nabi ﷺ mengucapkannya lebih dari 70 kali sehari", "Peygamber ﷺ günde yetmişten fazla söylerdi", "Le Prophète ﷺ le disait plus de soixante-dix fois par jour"),
    "salawat": ("Send one blessing, Allah sends you ten", "صلِّ عليه واحدة يصلِّ الله عليك عشرًا", "ایک درود پر اللہ دس رحمتیں بھیجتا ہے", "একবার দরুদে আল্লাহ দশবার রহমত দেন", "Satu shalawat, Allah membalas sepuluh", "Bir salavata Allah on rahmet eder", "Une prière sur lui, Allah vous en accorde dix"),
    "hasbunallah": ("Said by Ibrahim (AS) in the fire, and by the Prophet ﷺ", "قالها إبراهيم عليه السلام حين أُلقي في النار وقالها محمد ﷺ", "ابراہیم علیہ السلام نے آگ میں اور نبی ﷺ نے کہا", "ইবরাহিম (আ.) আগুনে নিক্ষিপ্ত হওয়ার সময় এবং নবী ﷺ বলেছিলেন", "Diucapkan Nabi Ibrahim a.s. saat dilempar ke api, dan oleh Nabi ﷺ", "Hz. İbrahim ateşe atılırken ve Peygamber ﷺ söyledi", "Dit par Ibrahim (paix sur lui) dans le feu, et par le Prophète ﷺ"),
    "yunus": ("The dua of Yunus (AS): whoever calls with it is answered", "دعوة ذي النون: ما دعا بها مسلم إلا استُجيب له", "یونس علیہ السلام کی دعا: جو اس سے مانگے، قبول ہو", "ইউনুস (আ.)-এর দোয়া: যে এ দিয়ে ডাকে, কবুল হয়", "Doa Nabi Yunus a.s.: siapa berdoa dengannya dikabulkan", "Hz. Yunus'un duası: onunla dua edene icabet edilir", "L'invocation de Younous (paix sur lui) : celui qui l'invoque est exaucé"),
    "juwairiya": ("Three times outweighs a morning of dhikr", "ثلاث مرات ترجح بذكر الصباح كله", "تین بار پوری صبح کے ذکر سے بھاری", "তিনবার পুরো সকালের জিকিরের চেয়ে ভারী", "Tiga kali lebih berat dari zikir sepagi", "Üç kez, bütün bir sabahın zikrinden ağır", "Trois fois pèse plus qu'une matinée de dhikr"),
    "after_salah": ("Never disappointed, after every prayer", "معقبات لا يخيب قائلهن", "ہر نماز کے بعد، کہنے والا محروم نہیں رہتا", "প্রতি নামাজের পর, পাঠকারী বঞ্চিত হয় না", "Setelah setiap salat, pengucapnya tak merugi", "Her namazdan sonra, söyleyen mahrum kalmaz", "Après chaque prière, celui qui les dit n'est jamais déçu"),
}

# (id, arabic, latin, Bangla reading, target, HadeethEnc id, HadeethEnc id holding the words or None)
DHIKR = [
    ("subhanallah", "سُبْحَانَ اللّٰهِ", "SubhanAllah", "সুবহানাল্লাহ", 33, 3762, 5475),
    ("alhamdulillah", "الْحَمْدُ لِلّٰهِ", "Alhamdulillah", "আলহামদুলিল্লাহ", 33, 66526, None),
    ("allahuakbar", "اللّٰهُ أَكْبَرُ", "Allahu Akbar", "আল্লাহু আকবার", 34, 5475, None),
    ("subhanallah_wabihamdihi", "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ", "SubhanAllahi wa bihamdihi", "সুবহানাল্লাহি ওয়া বিহামদিহি", 100, 5516, None),
    ("two_words", "سُبْحَانَ اللّٰهِ الْعَظِيمِ، سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ", "SubhanAllahil Azim, SubhanAllahi wa bihamdihi", "সুবহানাল্লাহিল আজিম, সুবহানাল্লাহি ওয়া বিহামদিহি", 33, 5507, None),
    ("four_words", "سُبْحَانَ اللّٰهِ، وَالْحَمْدُ لِلّٰهِ، وَلَا إِلٰهَ إِلَّا اللّٰهُ، وَاللّٰهُ أَكْبَرُ", "SubhanAllah, walhamdulillah, wa la ilaha illallah, wallahu akbar", "সুবহানাল্লাহ, ওয়াল হামদুলিল্লাহ, ওয়া লা ইলাহা ইল্লাল্লাহ, ওয়াল্লাহু আকবার", 33, 5475, None),
    ("tahlil", "لَا إِلٰهَ إِلَّا اللّٰهُ", "La ilaha illallah", "লা ইলাহা ইল্লাল্লাহ", 100, 3567, None),
    ("tahlil_full", "لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ", "La ilaha illallahu wahdahu la sharika lah, lahul mulku wa lahul hamd, wa huwa ala kulli shayin qadir", "লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারিকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া আলা কুল্লি শাইয়িন কাদির", 100, 65905, None),
    ("istighfar", "أَسْتَغْفِرُ اللّٰهَ وَأَتُوبُ إِلَيْهِ", "Astaghfirullaha wa atubu ilayh", "আস্তাগফিরুল্লাহা ওয়া আতুবু ইলাইহি", 100, 4808, None),
    ("salawat", "اللّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ", "Allahumma salli ala Muhammad", "আল্লাহুম্মা সাল্লি আলা মুহাম্মাদ", 10, 65928, 5377),
    ("hasbunallah", "حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكِيلُ", "Hasbunallahu wa nimal wakil", "হাসবুনাল্লাহু ওয়া নি'মাল ওয়াকিল", 33, 65287, None),
    ("yunus", "لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ", "La ilaha illa anta subhanaka inni kuntu minaz-zalimin", "লা ইলাহা ইল্লা আনতা সুবহানাকা ইন্নি কুনতু মিনাজ জালিমিন", 33, 65919, None),
    ("juwairiya", "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ", "SubhanAllahi wa bihamdihi, adada khalqihi, wa rida nafsihi, wa zinata arshihi, wa midada kalimatihi", "সুবহানাল্লাহি ওয়া বিহামদিহি, আদাদা খালকিহি, ওয়া রিদা নাফসিহি, ওয়া যিনাতা আরশিহি, ওয়া মিদাদা কালিমাতিহি", 3, 5508, None),
]
AFTER_SALAH = 6259  # Muslim 596

MARKS = re.compile("[ؐ-ًؚ-ٰٟۖ-ۭـ‌]")


def norm(s):
    s = MARKS.sub("", s or "")
    s = re.sub("[أإآٱ]", "ا", s).replace("ى", "ي").replace("ؤ", "و").replace("ئ", "ي").replace("ة", "ه")
    s = re.sub("[^ء-ي ]", " ", s)
    return " ".join(s.split())


def language(lang):
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, f"{lang}.sqlite")
    if not os.path.exists(path):
        req = urllib.request.Request(URL.format(lang), headers={"User-Agent": "waqt-data-builder"})
        with zipfile.ZipFile(io.BytesIO(urllib.request.urlopen(req, timeout=300).read())) as z:
            name = next(n for n in z.namelist() if n.endswith(".sqlite"))
            with open(path, "wb") as f:
                f.write(z.read(name))
    db = sqlite3.connect(path)
    db.row_factory = sqlite3.Row
    return {r["id"]: r for r in db.execute("SELECT * FROM hadeeths")}


def labels(key, table):
    return dict(zip(LANGS, table[key]))


def dart(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    he = {lang: language(lang) for lang in LANGS}
    ar = he["ar"]
    used = set()

    def check(i, where):
        r = ar.get(i)
        if r is None:
            raise SystemExit(f"{where}: HadeethEnc {i} does not exist")
        if any(w in (r["grade"] or "") for w in WEAK):
            raise SystemExit(f"{where}: HadeethEnc {i} is graded {r['grade']}")
        used.add(i)

    def item(key, i, when, where):
        # A string is the key of an item that is not on HadeethEnc and
        # carries its own reference (lib/data/sources/referenced.dart).
        if isinstance(i, str):
            row = {"he": 0, "key": i, "title": labels(key, L)}
            if when:
                row["when"] = when
            return row
        check(i, where)
        row = {"he": i, "title": labels(key, L)}
        if when:
            row["when"] = when
        return row

    days = {o: [item(k, i, w, o) for k, i, w in items] for o, items in DAYS.items()}
    moments = {m: [item(k, i, None, m) for k, i in items] for m, items in MOMENTS.items()}
    with open(os.path.join(ROOT, "assets", "sources", "days.json"), "w", encoding="utf8") as f:
        json.dump({"source": "HadeethEnc.com", "days": days, "moments": moments, "fasts": FASTS}, f,
                  ensure_ascii=False, separators=(",", ":"))

    lines = []
    for id_, arabic, latin, bn, target, src, words in DHIKR:
        check(src, id_)
        text = ar[words or src]["hadeeth"]
        if norm(arabic) not in norm(text):
            raise SystemExit(f"{id_}: its Arabic is not in HadeethEnc {words or src}")
        v = labels(id_, V)
        lines.append(
            f"  Dhikr({dart(id_)}, {dart(arabic)}, {dart(latin)}, {target}, he: {src}, names: {{'bn': {dart(bn)}}}, "
            f"virtue: {{{', '.join(f'{dart(k)}: {dart(x)}' for k, x in v.items())}}}),"
        )
    check(AFTER_SALAH, "after_salah")
    v = labels("after_salah", V)
    with open(os.path.join(ROOT, "lib", "features", "counter", "dhikr_data.dart"), "w", encoding="utf8") as f:
        f.write(
            "// Generated by tool/build_content.py from HadeethEnc.com. Do not edit.\n"
            "// ignore_for_file: lines_longer_than_80_chars\n\nimport 'dhikr.dart';\n\n"
            "const builtInDhikr = <Dhikr>[\n" + "\n".join(lines) + "\n];\n\n"
            f"const afterSalahHe = {AFTER_SALAH};\n"
            f"const afterSalahVirtue = {{{', '.join(f'{dart(k)}: {dart(x)}' for k, x in v.items())}}};\n"
        )

    # Every hadith Waqt points to, in every language HadeethEnc has it in.
    out = {}
    for i in sorted(used):
        entry = {}
        for lang in LANGS:
            r = he[lang].get(i)
            if r is None or not r["hadeeth"]:
                continue
            keys = r.keys()
            entry[lang] = {
                "title": r["title"],
                "text": r["hadeeth"],
                "attribution": r["attribution"],
                "grade": r["grade"],
                "explanation": r["explanation"],
                "version": r["version"] if "version" in keys else r["ar_version"],
            }
        out[str(i)] = entry
    with open(os.path.join(ROOT, "assets", "sources", "hadeethenc.json"), "w", encoding="utf8") as f:
        json.dump({"source": "HadeethEnc.com", "url": "https://hadeethenc.com",
                   "retrieved": datetime.date.today().isoformat(), "items": out}, f,
                  ensure_ascii=False, separators=(",", ":"))

    print(f"{len(used)} hadiths; per language:",
          {lang: sum(1 for e in out.values() if lang in e) for lang in LANGS})


if __name__ == "__main__":
    main()
