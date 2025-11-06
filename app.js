const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send('Hello from DEVO a Devops Agent Demo!');
});

app.listen(port, () => {
  console.log(`Demo app listening on port ${port}`);
});
