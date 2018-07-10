'use strict';

const exec = require('child_process').exec;
const arp = exec('sudo arp-scan -l');

arp.stdout.on('data', data => {
    console.log(`stdout: ${data}`);
});

arp.stderr.on('data', data => {
    console.log(`stderr: ${data}`);
});

arp.on('close', code => {
    console.log(`child process exited with code: ${code}`);
});
