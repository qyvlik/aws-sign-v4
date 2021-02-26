require('dotenv').config({path: __dirname + '/.env'});

const aws4 = require('aws4');

const NodeFetch = require('node-fetch');

async function fetch({method, scheme, host, path, headers, body}) {
    const url = `${scheme}://${host}${path}`;
    return await NodeFetch(url, {method, headers, body});
}

const get_opts = {
    scheme: 'http',
    host: 'localhost',
    path: '/my-object',
    service: 's3',
    region: 'us-west-1',
    method: 'GET'
};


const post_opts = {
    scheme: 'http',
    host: 'localhost',
    path: '/my-object',
    service: 's3',
    region: 'us-west-1',
    method: 'POST',
    body: 'xxxx'
};


async function get_test(index) {
    aws4.sign(get_opts);
    console.time(`openresty-aws-signv4:get:${index}`);
    const res = await fetch(get_opts);
    console.timeEnd(`openresty-aws-signv4:get:${index}`);
    const body = await res.text();
    // console.info(`body: \n${body}`);
    // console.info(get_opts);
}

async function post_test(index) {
    aws4.sign(post_opts);
    console.time(`openresty-aws-signv4:post:${index}`);
    const res = await fetch(post_opts);
    console.timeEnd(`openresty-aws-signv4:post:${index}`);
    const body = await res.text();
    // console.info(`body: \n${body}`);
    // console.info(post_opts);
}

(async () => {
    let index = 20;

    while (index-- > 0) {
        get_test(index);
        post_test(index);
    }
})();


