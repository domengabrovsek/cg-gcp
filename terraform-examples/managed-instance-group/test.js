(async () => {

    while (true) {
      const res = await fetch('http://34.118.67.197');
      const text = await res.text();
      const regex = /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/gm;
      const ip = text.match(regex)[0];

      console.log(`Response sent from ${ip} - ${new Date().toISOString()}`)
    }
  })();