const { Translate } = require('@google-cloud/translate').v2;
const { PubSub } = require('@google-cloud/pubsub');

const translateClient = new Translate();
const pubSubClient = new PubSub();
const resultTopic = process.env.RESULT_TOPIC;

exports.translateText = async (event, context) => {
  const message = JSON.parse(Buffer.from(event.data, 'base64').toString());
  const text = message.text;
  const filename = message.filename;
  const targetLang = message.lang;
  const srcLang = message.src_lang;

  console.log(`Translating text into ${targetLang}.`);
  const translatedText = await translateClient.translate(text, { from: srcLang, to: targetLang });
  const messageData = JSON.stringify({
    text: translatedText[0],
    filename,
    lang: targetLang,
  });
  const dataBuffer = Buffer.from(messageData);
  await pubSubClient.topic(resultTopic).publish(dataBuffer);
};