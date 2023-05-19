const { Storage } = require('@google-cloud/storage');

const storageClient = new Storage();
const resultBucket = process.env.RESULT_BUCKET

exports.saveResult = async (event, context) => {
  const message = JSON.parse(Buffer.from(event.data, 'base64').toString());
  const text = message.text;
  const filename = message.filename;
  const lang = message.lang;

  console.log(`Received request to save file ${filename}.`);

  const bucketName = resultBucket;
  const resultFilename = `${filename}_${lang}.txt`;
  const bucket = storageClient.bucket(bucketName);
  const file = bucket.file(resultFilename);

  console.log(`Saving result to ${resultFilename} in bucket ${bucketName}.`);

  await file.save(text, { metadata: { contentType: 'text/plain; charset=utf-8' } });
  console.log('File saved.');
};
