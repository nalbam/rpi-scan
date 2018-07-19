const os = require('os'),
    ip = require("ip"),
    moment = require('moment-timezone'),
    express = require('express');

const exec = require('child_process').exec;
const CronJob = require('cron').CronJob;

const token = process.env.LOGZIO_TOKEN || 'EMPTY_TOKEN';
const type = process.env.LOGZIO_TYPE || 'demo';

const logger = require('logzio-nodejs').createLogger({token: `${token}`, type: `${type}`});

const app = express();
app.set('view engine', 'ejs');
app.use('/favicon.ico', express.static('views/favicon.ico'));

app.get('/', function (req, res) {
    let host = os.hostname();
    let date = moment().tz('Asia/Seoul').format();
    res.render('index.ejs', {host: host, date: date, server: ip.address(), client: req.ip.split(':').pop()});
});

app.listen(3000, function () {
    console.log('Listening on port 3000!');
});

const job = new CronJob({
    cronTime: '0 * * * * *',
    onTick: function() {
        console.log('scan start.');
        const scan = exec('sudo arp-scan -l | grep -E "([0-9]{1,3}\\.){3}[0-9]{1,3}"');
        scan.stdout.on('data', data => {
            // console.log(`${data}`);
            data.split('\n').forEach(function (item) {
                const arr = item.split('\t');
                if (arr && arr[0]) {
                    logger.log({ip: arr[0], mac: arr[1], desc: arr[2]});
                }
                // console.log(`${item}`);
            });
            // console.log('scan done.');
        });

        scan.stderr.on('data', data => {
            console.log(`Error: ${data}`);
        });
    },
    start: false,
    timeZone: 'Asia/Seoul'
});

if (token !== 'EMPTY_TOKEN') {
    job.start();
}
