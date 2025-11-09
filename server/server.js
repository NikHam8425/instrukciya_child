import express from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

const PORT = 3000;

app.get('/health', (req, res) => {
  res.json({ ok: true, hasKey: Boolean(process.env.OPENAI_API_KEY) });
});

app.post('/ask', async (req, res) => {
  try {
    const { message, child } = req.body || {};
    if (!process.env.OPENAI_API_KEY) {
      return res.status(500).json({ error: 'OPENAI_API_KEY не задан' });
    }
    if (!message || typeof message !== 'string') {
      return res.status(400).json({ error: 'Параметр message обязателен' });
    }

    // Формируем системный промпт (ребёнок может быть null)
    const system = child ? 
      `Ты помощник для родителей. Учитывай профиль ребёнка: ${JSON.stringify(child)}` :
      'Ты помощник для родителей. Отвечай кратко и по делу.';

    // Используем популярную доступную модель
    const model = 'gpt-4o-mini';

    const payload = {
      model,
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: message }
      ],
      temperature: 0.4
    };

    const r = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const text = await r.text();

    // ЛОГИРОВАНИЕ ВСЕГО, ЧТО ПРИШЛО ОТ OPENAI
    console.log('OpenAI status:', r.status);
    console.log('OpenAI body  :', text);

    if (!r.ok) {
      return res.status(500).json({ error: 'OpenAI error', status: r.status, body: text });
    }

    const data = JSON.parse(text);
    const answer = data?.choices?.[0]?.message?.content?.trim() || '(пустой ответ)';
    return res.json({ answer });
  } catch (e) {
    console.error('SERVER ERROR:', e);
    return res.status(500).json({ error: 'Ошибка сервера', detail: String(e) });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Proxy сервер запущен на порту ${PORT}`);
});
