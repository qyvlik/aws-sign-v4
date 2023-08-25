require('dotenv').config({path: __dirname + '/.env'});

const aws4 = require('aws4');

const NodeFetch = require('node-fetch');

async function fetch({method, scheme, host, path, headers, body}) {
    const url = `${scheme}://${host}${path}`;
    return await NodeFetch(url, {method, headers, body});
}

const get_opts = {
    scheme: 'http',
    host: '127.0.0.1:8080',
    path: '/api/v1/simple-get',
    service: 'execute-api',
    region: 'us-west-1',
    method: 'GET'
};


const post_opts = {
    scheme: 'http',
    host: '127.0.0.1:8080',
    path: '/api/v1/simple-post',
    service: 'execute-api',
    region: 'us-east-1',
    method: 'POST',
    headers: {
        'content-type': 'application/json'
    },
    body: '{"name": "1"}'
};

// X-Amz-SignedHeaders=content-length%3Bcontent-type%3Bhost
// X-Amz-SignedHeaders=content-type%3Bhost

async function get_test(index) {
    const signer = new aws4.RequestSigner(get_opts);
    signer.request.signQuery = false;
    signer.sign();
    console.time(`openresty-aws-signv4:get:${index}`);
    const res = await fetch(get_opts);
    console.timeEnd(`openresty-aws-signv4:get:${index}`);
    const body = await res.text();
    console.info(`body: \n${body}`);
    console.info(get_opts);
}

async function post_test(index) {
    // aws4.sign(post_opts);
    const signer = new aws4.RequestSigner(post_opts);
    signer.request.signQuery = true;
    signer.sign();

    console.time(`openresty-aws-signv4:post:${index}`);
    const res = await fetch(post_opts);
    console.timeEnd(`openresty-aws-signv4:post:${index}`);
    const body = await res.text();
    console.info(`body: \n${body}`);
    console.info(post_opts);
}

(async () => {
    let index = 1;

    while (index-- > 0) {
        get_test(index);
        // post_test(index);
    }
})();


