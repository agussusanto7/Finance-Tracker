require('dotenv').config();
const TelegramBot = require('node-telegram-bot-api');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// 1. Inisialisasi Firebase Admin
// Pastikan file firebase-service-account.json sudah didownload dan diletakkan di folder ini
try {
  const serviceAccount = require('./firebase-service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log("✅ Firebase berhasil dikonfigurasi.");
} catch (error) {
  console.error("❌ ERROR: File firebase-service-account.json tidak ditemukan atau tidak valid!");
  console.log("Pastikan kamu sudah mengikuti Panduan Langkah 2.");
  process.exit(1);
}

const db = admin.firestore();

// 2. Inisialisasi Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ 
  model: "gemini-3.1-flash-lite",
  systemInstruction: `Kamu adalah asisten pengatur keuangan. Pengguna akan memberikan kalimat natural untuk mencatat keuangan ATAU menanyakan soal keuangannya. 
Data riwayat transaksi akan diberikan di dalam prompt pengguna. Gunakan data tersebut untuk menjawab pertanyaan.

Tugasmu adalah menganalisis niat pengguna dan mengembalikan HANYA format JSON yang valid TANPA markdown (jangan pakai \`\`\`json).

Format JSON: 
{
  "action": "record" | "chat",
  "reply": "Jawaban santai dan ramah jika action=chat (wajib gunakan data riwayat untuk menjawab pertanyaan dengan akurat), kosongkan jika action=record",
  "transaction_data": {
    "amount": number, 
    "type": "pemasukan" atau "pengeluaran", 
    "category": "Makanan/Transportasi/Belanja/Hiburan/Kesehatan/Tagihan/Pendidikan/Olahraga/Liburan/Rumah/Lainnya/Gaji/Bonus/Investasi/Hadiah", 
    "note": "string"
  } // Isi dengan null jika action=chat
}`
});

// 3. Inisialisasi Telegram Bot
const token = process.env.TELEGRAM_BOT_TOKEN;
if (!token || token === 'TOKEN_TELEGRAM_KAMU_DISINI') {
  console.error("❌ ERROR: TELEGRAM_BOT_TOKEN belum diisi di file .env!");
  process.exit(1);
}

const bot = new TelegramBot(token, { polling: true });
const API_KEY = process.env.FIREBASE_WEB_API_KEY;

console.log("🤖 Bot Telegram sudah berjalan! Siap menerima pesan...");

// 4. Dummy Web Server (WAJIB UNTUK HOSTING DI RENDER/HEROKU)
// Platform hosting butuh server yang listen ke PORT agar deploy tidak dianggap gagal.
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Finance Tracker Telegram Bot is Running!');
});
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🌐 Dummy Web Server berjalan di port ${PORT} (Untuk keperluan Hosting)`);
});

// Helper function untuk mendapatkan sesi pengguna
async function getUserSession(chatId) {
  const doc = await db.collection('telegram_sessions').doc(chatId.toString()).get();
  if (doc.exists) {
    return doc.data().uid;
  }
  return null;
}

// Command /start
bot.onText(/\/start/, (msg) => {
  const chatId = msg.chat.id;
  const welcomeMsg = `Halo ${msg.from.first_name}! 👋\nSaya adalah Bot FinanceTracker.\n\nKarena ini sistem aman, kamu harus menautkan akunmu.\n\nKetik dengan format:\n/login_uid <UID_KAMU>\n\n*(Kamu bisa mendapatkan UID dari Firebase Console > Authentication)*`;
  bot.sendMessage(chatId, welcomeMsg);
});

// Command /login_uid (Cara Cepat)
bot.onText(/\/login_uid (.+)/, async (msg, match) => {
  const chatId = msg.chat.id;
  const uid = match[1].trim();

  bot.sendMessage(chatId, "⏳ Sedang menautkan akun...");

  try {
    // Verifikasi apakah UID tersebut ada di database (Opsional, tapi bagus untuk keamanan)
    const userDoc = await db.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      bot.sendMessage(chatId, `❌ Gagal: UID tersebut tidak ditemukan di database aplikasi. Pastikan kamu sudah copy dengan benar!`);
      return;
    }

    // Simpan sesi ke Firestore
    await db.collection('telegram_sessions').doc(chatId.toString()).set({
      uid: uid,
      email: userDoc.data().email || 'Linked via UID',
      created_at: new Date()
    });

    bot.sendMessage(chatId, `✅ Berhasil Terhubung!\n\nAkun Telegram ini sudah terhubung dengan aplikasi FinanceTracker milikmu.\n\nKamu bisa mencatat keuanganmu dengan nge-chat saya, contoh:\n"makan siang nasi padang 25rb"\n"dapat gaji 5 juta"\n\nKetik /saldo untuk melihat saldo saat ini.`);
  } catch (error) {
    console.error(error);
    bot.sendMessage(chatId, "❌ Terjadi kesalahan saat mencoba menautkan akun.");
  }
});

// Command /logout
bot.onText(/\/logout/, async (msg) => {
  const chatId = msg.chat.id;
  await db.collection('telegram_sessions').doc(chatId.toString()).delete();
  bot.sendMessage(chatId, "👋 Kamu telah berhasil logout dari bot Telegram ini.");
});

// Command /saldo
bot.onText(/\/saldo/, async (msg) => {
  const chatId = msg.chat.id;
  
  const uid = await getUserSession(chatId);
  if (!uid) {
    bot.sendMessage(chatId, "⚠️ Kamu belum menautkan akun! Silakan ketik: `/login_uid UID_KAMU`", { parse_mode: 'Markdown' });
    return;
  }

  const userTransactionsRef = db.collection('users').doc(uid).collection('transactions');
  bot.sendMessage(chatId, "⏳ Sedang menghitung saldo...");

  try {
    const snapshot = await userTransactionsRef.get();
    let totalIncome = 0;
    let totalExpense = 0;

    snapshot.forEach((doc) => {
      const data = doc.data();
      if (data.type === 'pemasukan') {
        totalIncome += data.amount;
      } else if (data.type === 'pengeluaran') {
        totalExpense += data.amount;
      }
    });

    const balance = totalIncome - totalExpense;
    
    // Format mata uang Rupiah
    const formatter = new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0
    });

    const reply = `📊 *Ringkasan Keuanganmu:*\n\n💰 *Total Saldo:* ${formatter.format(balance)}\n\n🟢 Pemasukan: ${formatter.format(totalIncome)}\n🔴 Pengeluaran: ${formatter.format(totalExpense)}`;
    bot.sendMessage(chatId, reply, { parse_mode: 'Markdown' });
  } catch (error) {
    console.error("Gagal mengambil data saldo:", error);
    bot.sendMessage(chatId, "❌ Terjadi kesalahan saat mengambil data saldo.");
  }
});

// Menangani pesan teks biasa ATAU Foto (pencatatan otomatis dengan AI)
bot.on('message', async (msg) => {
  const chatId = msg.chat.id;
  const text = msg.text || msg.caption || ''; // Ambil teks atau caption foto

  // Abaikan command yang dimulai dengan "/"
  if (text.startsWith('/')) return;
  
  // Jika tidak ada teks dan tidak ada foto, abaikan
  if (!text && !msg.photo) return;

  const uid = await getUserSession(chatId);
  if (!uid) {
    bot.sendMessage(chatId, "⚠️ Kamu belum menautkan akun! Silakan ketik: `/login_uid UID_KAMU`", { parse_mode: 'Markdown' });
    return;
  }

  const userTransactionsRef = db.collection('users').doc(uid).collection('transactions');
  
  bot.sendMessage(chatId, "🤖 AI sedang menganalisa transaksi...");

  try {
    let aiResponse = "";
    
    // AMBIL DATA TRANSAKSI UNTUK KONTEKS AI (Maksimal 50 transaksi terakhir)
    const snapshot = await userTransactionsRef.orderBy('date', 'desc').limit(50).get();
    let historyContext = "RIWAYAT TRANSAKSI TERAKHIR (Gunakan ini untuk menjawab jika user bertanya):\n";
    let currentIncome = 0;
    let currentExpense = 0;
    
    snapshot.forEach(doc => {
      const tx = doc.data();
      historyContext += `- [${tx.date}] ${tx.type}: Rp${tx.amount} (${tx.category}) - ${tx.note}\n`;
      if (tx.type === 'pemasukan') currentIncome += tx.amount;
      else currentExpense += tx.amount;
    });
    const balance = currentIncome - currentExpense;
    historyContext += `\nTOTAL SEMENTARA (dari 50 transaksi terakhir):\nPemasukan: Rp${currentIncome}\nPengeluaran: Rp${currentExpense}\nSaldo: Rp${balance}\n\n`;
    historyContext += `PESAN DARI USER:\n${text}`;

    // JIKA ADA FOTO STRUK
    let publicImageUrl = null;
    if (msg.photo) {
      // Ambil foto dengan resolusi tertinggi (paling akhir di array)
      const fileId = msg.photo[msg.photo.length - 1].file_id;
      const fileLink = await bot.getFileLink(fileId);
      
      // Download gambar dan ubah ke format Base64 untuk dikirim ke Gemini
      const imageResp = await fetch(fileLink);
      const arrayBuffer = await imageResp.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      
      const imageParts = [
        {
          inlineData: {
            data: buffer.toString("base64"),
            mimeType: "image/jpeg"
          }
        }
      ];

      // Minta AI membaca gambar
      const prompt = `Analisa gambar struk/bukti transfer ini dan catat transaksinya. \n${historyContext}`;
      const result = await model.generateContent([prompt, ...imageParts]);
      aiResponse = result.response.text();

      // UPLOAD FOTO KE SUPABASE STORAGE AGAR MUNCUL DI APLIKASI
      try {
        const supabaseUrl = process.env.SUPABASE_URL;
        const supabaseKey = process.env.SUPABASE_ANON_KEY;
        const fileName = `receipt_${Date.now()}.jpg`;
        const storagePath = `${uid}/receipts/${fileName}`;
        
        const uploadUrl = `${supabaseUrl}/storage/v1/object/receipts/${storagePath}`;
        
        const uploadResponse = await fetch(uploadUrl, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${supabaseKey}`,
            'Content-Type': 'image/jpeg'
          },
          body: buffer
        });

        if (uploadResponse.ok) {
          publicImageUrl = `${supabaseUrl}/storage/v1/object/public/receipts/${storagePath}`;
          console.log("✅ Berhasil upload foto ke Supabase:", publicImageUrl);
        } else {
          console.error("❌ Gagal upload ke Supabase:", await uploadResponse.text());
        }
      } catch (e) {
        console.error("❌ Error saat upload gambar ke Supabase:", e);
      }
    } 
    // JIKA HANYA TEKS BIASA
    else {
      const result = await model.generateContent(historyContext);
      aiResponse = result.response.text();
    }
    
    // Parse JSON dari AI
    let parsedData;
    try {
      // Hilangkan backticks markdown jika AI masih mengirimkannya
      const cleanJson = aiResponse.replace(/```json/g, '').replace(/```/g, '').trim();
      parsedData = JSON.parse(cleanJson);
    } catch (e) {
      console.log("Raw AI response:", aiResponse);
      bot.sendMessage(chatId, "❌ Maaf, saya tidak mengerti. Coba gunakan kalimat yang lebih jelas.");
      return;
    }

    // JIKA USER HANYA BERTANYA (NGOBROL)
    if (parsedData.action === 'chat' || !parsedData.transaction_data || parsedData.transaction_data.amount === 0 || !parsedData.transaction_data.amount) {
      bot.sendMessage(chatId, parsedData.reply || "Saya tidak menemukan data yang relevan.");
      return;
    }

    // JIKA MENCATAT TRANSAKSI
    const transactionData = parsedData.transaction_data;
    const now = new Date();
    const pad = (n) => n.toString().padStart(2, '0');
    const dateFormatted = `${now.getFullYear()}-${pad(now.getMonth()+1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;

    const newTxRef = userTransactionsRef.doc();
    
    // Format ID seperti di aplikasi Flutter
    const prefix = transactionData.type === 'pemasukan' ? 'pemasukan' : 'pengeluaran';
    const docId = `${prefix}_${newTxRef.id}`;

    const dataToSave = {
      id: docId,
      amount: transactionData.amount,
      type: transactionData.type === 'pemasukan' ? 'pemasukan' : 'pengeluaran',
      category: transactionData.category || (transactionData.type === 'pemasukan' ? 'Lainnya' : 'Lainnya'),
      date: dateFormatted,
      note: transactionData.note || (text ? text : "Scan Struk Otomatis"),
      image_path: publicImageUrl, // Menambahkan URL gambar dari Supabase
      created_at: dateFormatted
    };

    // Simpan dokumen ke akun spesifik
    await userTransactionsRef.doc(docId).set(dataToSave);

    // 3. Beri balasan berhasil
    const formatter = new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0
    });

    const icon = transactionData.type === 'pemasukan' ? '🟢' : '🔴';
    const reply = `✅ *Transaksi Berhasil Dicatat!*\n\n${icon} Tipe: ${transactionData.type}\n💰 Nominal: ${formatter.format(transactionData.amount)}\n📁 Kategori: ${dataToSave.category}\n📝 Catatan: ${dataToSave.note}`;
    
    bot.sendMessage(chatId, reply, { parse_mode: 'Markdown' });

  } catch (error) {
    console.error("Error processing transaction:", error);
    bot.sendMessage(chatId, "❌ Terjadi kesalahan saat memproses transaksi/gambar.");
  }
});
