const vision = require('@google-cloud/vision');
const { Translate } = require('@google-cloud/translate').v2;
const { PubSub } = require('@google-cloud/pubsub');

const visionClient = new vision.ImageAnnotatorClient();
const translateClient = new Translate();
const pubSubClient = new PubSub();

const resultTopic = process.env.RESULT_TOPIC;
const translateTopic = process.env.TRANSLATE_TOPIC;
const languages = ['en', 'de', 'fr', 'es', 'it', 'ja', 'ko', 'pt', 'ru', 'zh'];

async function detectText(bucket, filename) {
  console.log(`Looking for text in image ${filename}`);

  const textDetectionResponse = await visionClient.textDetection(`gs://${bucket}/${filename}`);
  const annotations = textDetectionResponse[0].textAnnotations;
  let text = '';
  if (annotations.length > 0) {
    text = annotations[0].description;
  }
  console.log(`Extracted text ${text} from image (${text.length} chars).`);

  const detectLanguageResponse = await translateClient.detect(text);
  const srcLang = detectLanguageResponse[0].language;
  console.log(`Detected language ${srcLang} for text ${text}.`);

  for (const targetLang of languages) {
    const topicName = srcLang === targetLang || srcLang === 'und' ? resultTopic : translateTopic;
    const message = JSON.stringify({
      text,
      filename,
      lang: targetLang,
      src_lang: srcLang,
    });
    const dataBuffer = Buffer.from(message);
    await pubSubClient.topic(topicName).publish(dataBuffer);
  }
}

exports.processImage = async (event, context) => {
  const file = event;
  const bucket = file.bucket;
  const name = file.name;

  await detectText(bucket, name);

  console.log(`File ${file.name} processed.`);
};