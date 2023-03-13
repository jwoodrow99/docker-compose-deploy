const express = require('express');

const app = express();

app.get('/', (req, res) => {
	res.send('Hello World! From Node.');
});

app.listen(9000, () => console.log('Server is up and running!'));
