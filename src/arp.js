'use strict';

const exec = require('child_process').exec;
const CronJob = require('cron').CronJob;

const token = process.env.LOGZIO_TOKEN || '';

const logger = require('logzio-nodejs').createLogger({
    token: `${token}`,
    host: 'listener.logz.io',
    type: 'demo'     // OPTIONAL (If none is set, it will be 'nodejs')
});

var job = new CronJob({
    cronTime: '0 * * * * *',
    onTick: function() {
        console.log('job start.');

        const arp = exec('sudo arp-scan -l | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}"');

        arp.stdout.on('data', data => {
            // console.log(`${data}`);

            var arr = data.split("\n");

            arr.forEach(function (item) {
                var a = item.split("\t");

                if (!a || !a[0]) {
                    continue;
                }

                var obj = {
                    ip: a[0],
                    mac: a[1],
                    desc: a[2]
                };

                logger.log(obj);

                // console.log(`${item}`);
            });

            console.log('done.');
        });

        arp.stderr.on('data', data => {
            console.log(`Error: ${data}`);
        });

        arp.on('close', code => {
            // console.log(`child process exited with code: ${code}`);
        });
    },
    start: false,
    timeZone: 'Asia/Seoul'
});

if (token) {
    job.start();
}
