const TelegramBot = require('node-telegram-bot-api');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// 1. Inisialisasi Firebase Admin (Aman untuk Vercel Serverless)
if (!admin.apps.length) {
    try {
        // Di Vercel, kita mengambil file JSON dari Environment Variable FIREBASE_SERVICE_ACCOUNT
        let serviceAccount;
        if (process.env.FIREBASE_SERVICE_ACCOUNT) {
            serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
        } else {
            // Fallback untuk local testing
            serviceAccount = require('../firebase-service-account.json');
        }

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log("✅ Firebase berhasil dikonfigurasi.");
    } catch (error) {
        console.error("❌ ERROR Firebase Init:", error);
    }
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
  "reply": "Jawaban profesional jika action=chat. Wajib gunakan riwayat. Gunakan struktur layout yang sangat elegan. Berikan jarak antar baris kosong ganda agar tidak sumpek di HP. Tulis judul dengan bold (gunakan SATU asterisk *tebal*, misal: *🟢 PEMASUKAN*). Buat daftar transaksi secara terstruktur, sertakan nama hari. Contoh format ideal: \n📅 _Rabu, 5 Jun 2026 14:00_ \n💬 Rp50.000 (Makanan) - Catatan. \nGunakan pemisah garis datar ────────────── antar bagian. Kosongkan jika action=record",
  "transaction_data": {
    "amount": number, 
    "type": "pemasukan" atau "pengeluaran", 
    "category": "Makanan/Transportasi/Belanja/Hiburan/Kesehatan/Tagihan/Pendidikan/Olahraga/Liburan/Rumah/Lainnya/Gaji/Bonus/Investasi/Hadiah", 
    "note": "string"
  } // Isi dengan null jika action=chat
}`
});

// 3. Inisialisasi Telegram Bot (Tanpa Polling untuk Vercel)
const token = process.env.TELEGRAM_BOT_TOKEN;
const bot = new TelegramBot(token); // Polling dihapus

// Helper function untuk mendapatkan sesi pengguna
async function getUserSession(chatId) {
    const doc = await db.collection('telegram_sessions').doc(chatId.toString()).get();
    if (doc.exists) {
        return doc.data().uid;
    }
    return null;
}

// FUNGSI UTAMA UNTUK MENANGANI PESAN SECARA ASYNC DI VERCEL
async function handleUpdate(body) {
    if (!body.message) return;
    const msg = body.message;
    const chatId = msg.chat.id;
    const text = msg.text || msg.caption || '';

    try {
        // 1. COMMAND /start
        if (text.startsWith('/start')) {
            const welcomeMessage = `Halo! 👋 Saya adalah Bot Finance Tracker.
      
Untuk memulai, silakan tautkan akun aplikasi Finance Tracker-mu.
Ketik: \`/login_uid UID_KAMU\`

*(Kamu bisa melihat UID-mu di dalam aplikasi Flutter > Profil)*`;
            await bot.sendMessage(chatId, welcomeMessage, { parse_mode: 'Markdown' });
            return;
        }

        // 2. COMMAND /login_uid
        if (text.startsWith('/login_uid')) {
            const parts = text.split(' ');
            if (parts.length < 2) {
                await bot.sendMessage(chatId, "❌ Format salah. Gunakan: `/login_uid UID_KAMU`", { parse_mode: 'Markdown' });
                return;
            }
            const uid = parts[1];
            await bot.sendMessage(chatId, "⏳ Memverifikasi UID...");

            const userDoc = await db.collection('users').doc(uid).get();
            if (userDoc.exists) {
                await db.collection('telegram_sessions').doc(chatId.toString()).set({
                    uid: uid,
                    login_at: admin.firestore.FieldValue.serverTimestamp()
                });
                const userData = userDoc.data();
                await bot.sendMessage(chatId, `✅ Login Berhasil!\n\nSelamat datang, *${userData.name || userData.email || 'Pengguna'}*.\nSekarang kamu bisa mencatat transaksi atau mengecek saldo langsung dari sini.`, { parse_mode: 'Markdown' });
            } else {
                await bot.sendMessage(chatId, "❌ UID tidak ditemukan di database. Pastikan kamu mengcopy UID yang benar dari aplikasi.");
            }
            return;
        }

        // 3. COMMAND /logoutttttttttttttt
        if (text.startsWith('/logout')) {
            await db.collection('telegram_sessions').doc(chatId.toString()).delete();
            await bot.sendMessage(chatId, "✅ Berhasil logout dari bot Telegram.");
            return;
        }

        // 4. COMMAND /saldo
        if (text.startsWith('/saldo')) {
            const uid = await getUserSession(chatId);
            if (!uid) {
                await bot.sendMessage(chatId, "⚠️ Kamu belum menautkan akun! Silakan ketik: `/login_uid UID_KAMU`", { parse_mode: 'Markdown' });
                return;
            }

            await bot.sendMessage(chatId, "⏳ Menghitung saldo dari database...");
            const transactionsSnapshot = await db.collection('users').doc(uid).collection('transactions').get();

            let totalIncome = 0;
            let totalExpense = 0;

            transactionsSnapshot.forEach(doc => {
                const data = doc.data();
                if (data.type === 'pemasukan') {
                    totalIncome += data.amount;
                } else if (data.type === 'pengeluaran') {
                    totalExpense += data.amount;
                }
            });

            const balance = totalIncome - totalExpense;
            const formatter = new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 });
            const reply = `📊 *Ringkasan Keuanganmu:*\n\n💰 *Total Saldo:* ${formatter.format(balance)}\n\n🟢 Pemasukan: ${formatter.format(totalIncome)}\n🔴 Pengeluaran: ${formatter.format(totalExpense)}`;
            await bot.sendMessage(chatId, reply, { parse_mode: 'Markdown' });
            return;
        }

        // 5. COMMAND /export (Download Laporan Excel/CSV)
        if (text.startsWith('/export')) {
            const uid = await getUserSession(chatId);
            if (!uid) {
                await bot.sendMessage(chatId, "⚠️ Kamu belum menautkan akun! Silakan ketik: `/login_uid UID_KAMU`", { parse_mode: 'Markdown' });
                return;
            }

            await bot.sendMessage(chatId, "⏳ Sedang menyusun laporan Excel (CSV)...");
            const snapshot = await db.collection('users').doc(uid).collection('transactions').orderBy('date', 'desc').get();

            if (snapshot.empty) {
                await bot.sendMessage(chatId, "❌ Kamu belum memiliki riwayat transaksi.");
                return;
            }

            let csvString = "Tanggal,Tipe,Kategori,Nominal,Catatan\n";
            snapshot.forEach(doc => {
                const data = doc.data();
                const date = data.date || '-';
                const type = data.type || '-';
                const category = data.category || '-';
                const amount = data.amount || 0;
                const note = data.note ? data.note.replace(/,/g, ' ') : '-'; // Hapus koma agar tidak merusak format CSV
                csvString += `${date},${type},${category},${amount},${note}\n`;
            });

            // Tambahkan BOM agar bisa terbaca sempurna oleh Microsoft Excel
            const buffer = Buffer.from('\uFEFF' + csvString, 'utf-8');

            await bot.sendDocument(chatId, buffer, {
                caption: "📄 Laporan Riwayat Transaksimu berhasil dibuat dan siap di-download!"
            }, {
                filename: `Laporan_Keuangan.csv`,
                contentType: 'text/csv'
            });
            return;
        }

        // 6. PESAN BIASA ATAU FOTO (PENCATATAN / CHAT AI)
        if (text.startsWith('/')) return; // Abaikan command lain
        if (!text && !msg.photo) return;

        const uid = await getUserSession(chatId);
        if (!uid) {
            await bot.sendMessage(chatId, "⚠️ Kamu belum menautkan akun! Silakan ketik: `/login_uid UID_KAMU`", { parse_mode: 'Markdown' });
            return;
        }

        const userTransactionsRef = db.collection('users').doc(uid).collection('transactions');
        await bot.sendMessage(chatId, "🤖 AI sedang memproses pesan...");

        let aiResponse = "";
        const snapshot = await userTransactionsRef.orderBy('date', 'desc').limit(50).get();
        let historyContext = "RIWAYAT TRANSAKSI TERAKHIR (Gunakan ini untuk menjawab jika user bertanya):\n";
        let currentIncome = 0;
        let currentExpense = 0;

        snapshot.forEach(doc => {
            const tx = doc.data();
            let dateStr = tx.date;
            try {
                const d = new Date(tx.date.replace(' ', 'T'));
                if (!isNaN(d.getTime())) {
                    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                    dateStr = `${days[d.getDay()]}, ${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()} ${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`;
                }
            } catch (e) {}
            historyContext += `- [${dateStr}] ${tx.type}: Rp${tx.amount} (${tx.category}) - ${tx.note}\n`;
            if (tx.type === 'pemasukan') currentIncome += tx.amount;
            else currentExpense += tx.amount;
        });
        const balance = currentIncome - currentExpense;
        historyContext += `\nTOTAL SEMENTARA (dari 50 transaksi terakhir):\nPemasukan: Rp${currentIncome}\nPengeluaran: Rp${currentExpense}\nSaldo: Rp${balance}\n\n`;
        historyContext += `PESAN DARI USER:\n${text}`;

        let publicImageUrl = null;
        if (msg.photo) {
            const fileId = msg.photo[msg.photo.length - 1].file_id;
            const fileLink = await bot.getFileLink(fileId);
            const imageResp = await fetch(fileLink);
            const arrayBuffer = await imageResp.arrayBuffer();
            const buffer = Buffer.from(arrayBuffer);

            const imageParts = [{ inlineData: { data: buffer.toString("base64"), mimeType: "image/jpeg" } }];
            const prompt = `Analisa gambar struk/bukti transfer ini dan catat transaksinya. \n${historyContext}`;
            const result = await model.generateContent([prompt, ...imageParts]);
            aiResponse = result.response.text();

            try {
                const supabaseUrl = process.env.SUPABASE_URL;
                const supabaseKey = process.env.SUPABASE_ANON_KEY;
                const fileName = `receipt_${Date.now()}.jpg`;
                const storagePath = `${uid}/receipts/${fileName}`;
                const uploadUrl = `${supabaseUrl}/storage/v1/object/receipts/${storagePath}`;

                const uploadResponse = await fetch(uploadUrl, {
                    method: 'POST',
                    headers: { 'Authorization': `Bearer ${supabaseKey}`, 'Content-Type': 'image/jpeg' },
                    body: buffer
                });

                if (uploadResponse.ok) {
                    publicImageUrl = `${supabaseUrl}/storage/v1/object/public/receipts/${storagePath}`;
                }
            } catch (e) {
                console.error("Supabase Error:", e);
            }
        } else {
            const result = await model.generateContent(historyContext);
            aiResponse = result.response.text();
        }

        let parsedData;
        try {
            const cleanJson = aiResponse.replace(/```json/g, '').replace(/```/g, '').trim();
            parsedData = JSON.parse(cleanJson);
        } catch (e) {
            await bot.sendMessage(chatId, "❌ Maaf, saya tidak mengerti. Coba gunakan kalimat yang lebih jelas.");
            return;
        }

        if (parsedData.action === 'chat' || !parsedData.transaction_data || !parsedData.transaction_data.amount) {
            const replyText = parsedData.reply || "Saya tidak menemukan data yang relevan.";
            try {
                await bot.sendMessage(chatId, replyText, { parse_mode: 'Markdown' });
            } catch (err) {
                // Fallback jika format Markdown yang di-generate AI error/tidak valid
                await bot.sendMessage(chatId, replyText);
            }
            return;
        }

        const transactionData = parsedData.transaction_data;
        // Sesuaikan waktu ke zona waktu Indonesia (WIB / UTC+7) karena Vercel menggunakan UTC
        const now = new Date(new Date().getTime() + (7 * 60 * 60 * 1000));
        const pad = (n) => n.toString().padStart(2, '0');
        const dateFormatted = `${now.getUTCFullYear()}-${pad(now.getUTCMonth()+1)}-${pad(now.getUTCDate())} ${pad(now.getUTCHours())}:${pad(now.getUTCMinutes())}:${pad(now.getUTCSeconds())}`;

        const newTxRef = userTransactionsRef.doc();
        const prefix = transactionData.type === 'pemasukan' ? 'pemasukan' : 'pengeluaran';
        const docId = `${prefix}_${newTxRef.id}`;

        const dataToSave = {
            id: docId,
            amount: transactionData.amount,
            type: transactionData.type === 'pemasukan' ? 'pemasukan' : 'pengeluaran',
            category: transactionData.category || 'Lainnya',
            date: dateFormatted,
            note: transactionData.note || (text ? text : "Scan Struk Otomatis"),
            image_path: publicImageUrl,
            created_at: dateFormatted
        };

        await userTransactionsRef.doc(docId).set(dataToSave);

        const formatter = new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 });
        const icon = transactionData.type === 'pemasukan' ? '🟢' : '🔴';
        const reply = `✅ *Transaksi Berhasil Dicatat!*\n\n${icon} Tipe: ${transactionData.type}\n💰 Nominal: ${formatter.format(transactionData.amount)}\n📁 Kategori: ${dataToSave.category}\n📝 Catatan: ${dataToSave.note}`;

        await bot.sendMessage(chatId, reply, { parse_mode: 'Markdown' });
    } catch (error) {
        console.error("Handler Error:", error);
        await bot.sendMessage(chatId, "❌ Terjadi kesalahan saat memproses pesan.");
    }
}

// VERCEL SERVERLESS HANDLER
module.exports = async(request, response) => {
    try {
        if (request.method === 'POST') {
            const { body } = request;
            if (body) {
                // TUNGGU PROSES SELESAI SEBELUM MENGIRIM RESPONSE 200 OK
                await handleUpdate(body);
            }
        }
        response.status(200).send('OK');
    } catch (error) {
        console.error("Webhook Error:", error);
        response.status(500).send('Error');
    }
};