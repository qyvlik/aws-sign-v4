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


(async () => {
    let index = 10;

    while (index-- > 0) {
        {
            aws4.sign(get_opts);
            console.time("openresty-aws-signv4:get");
            const res = await fetch(get_opts);
            console.timeEnd("openresty-aws-signv4:get");
            const body = await res.text();
            console.info(`body: \n${body}`);
            console.info(get_opts);
        }
        {
            aws4.sign(post_opts);
            console.time("openresty-aws-signv4:post");
            const res = await fetch(post_opts);
            console.timeEnd("openresty-aws-signv4:post");
            const body = await res.text();
            console.info(`body: \n${body}`);
            console.info(post_opts);
        }
    }


})();


