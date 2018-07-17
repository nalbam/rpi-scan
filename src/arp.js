'use strict';

const exec = require('child_process').exec;
const CronJob = require('cron').CronJob;

const token = process.env.LOGZIO_TOKEN || 'EMPTY_TOKEN';
const type = process.env.LOGZIO_TYPE || 'demo';

const logger = require('logzio-nodejs').createLogger({
    token: `${token}`,
    type: `${type}`
});

let job = new CronJob({
    cronTime: '0 * * * * *',
    onTick: function() {
        console.log('job start.');

        let scan = exec('sudo arp-scan -l | grep -E "([0-9]{1,3}\\.){3}[0-9]{1,3}"');

        scan.stdout.on('data', data => {
            // console.log(`${data}`);

            let arr = data.split('\n');

            arr.forEach(function (item) {
                let a = item.split('\t');

                if (a && a[0]) {
                    let obj = {
                        ip: a[0],
                        mac: a[1],
                        desc: a[2]
                    };

                    logger.log(obj);
                }

                // console.log(`${item}`);
            });

            console.log('done.');
        });

        scan.stderr.on('data', data => {
            console.log(`Error: ${data}`);
        });

        scan.on('close', code => {
            console.log(`child process exited with code: ${code}`);
        });
    },
    start: false,
    timeZone: 'Asia/Seoul'
});

if (token !== 'EMPTY_TOKEN') {
    job.start();
}
