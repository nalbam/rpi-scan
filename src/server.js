const os = require('os'),
    ip = require('ip'),
    moment = require('moment-timezone'),
    express = require('express'),
    request = require('request');

const exec = require('child_process').exec;
const CronJob = require('cron').CronJob;

const lambda = process.env.LAMBDA_API || '';

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
            console.log(`call: ${lambda}`);

            data.split('\n').forEach(function (item) {
                const arr = item.split('\t');

                if (arr && arr[0]) {
                    console.log(`body: ${arr[1]} ${arr[0]} ${arr[2]}`);

                    // call lambda api
                    request.post(`${lambda}`, {
                        json: {
                            ip: arr[0],
                            mac: arr[1],
                            desc: arr[2]
                        }
                    }, (error, res, body) => {
                        if (error) {
                            console.error(error);
                            return;
                        }
                        console.log(`statusCode: ${res.statusCode}`);
                        console.log(body);
                    });
                }
            });
            console.log('scan done.');
        });

        scan.stderr.on('data', data => {
            console.log(`Error: ${data}`);
        });
    },
    start: false,
    timeZone: 'Asia/Seoul'
});

if (lambda) {
    job.start();
}
