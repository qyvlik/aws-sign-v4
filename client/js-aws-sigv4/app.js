require('dotenv').config({path: __dirname + '/.env'});

const aws4 = require('aws4');

const NodeFetch = require('node-fetch');

async function fetch({method, scheme, host, path, headers, body}) {
    const url = `${scheme}://${host}${path}`;
    return await NodeFetch(url, {method, headers, body});
}

const opts = {
    scheme: 'http',
    host: 'localhost:3001',
    path: '/my-object',
    service: 's3',
    region: 'us-west-1',
    method: 'POST'
};


// aws4.sign() will sign and modify these options, ready to pass to http.request
aws4.sign(opts);
console.info(opts);

(async () => {
    const res = await fetch(opts);
    const body = await res.text();
    console.info(`body: \n${body}`);
})();


