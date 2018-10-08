const os = require('os'),
    ip = require('ip'),
    moment = require('moment-timezone'),
    express = require('express'),
    request = require('request');

const exec = require('child_process').exec;
const CronJob = require('cron').CronJob;

const scan_shell = process.env.SCAN_SHELL || '';
const lambda_api = process.env.LAMBDA_API || '';
const lambda_key = process.env.LAMBDA_KEY || '';

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
    cronTime: '0 */10 * * * *',
    onTick: function() {
        console.log('scan start.');

        const scan = exec(`${scan_shell}`);
        scan.stdout.on('data', data => {
            console.log(`call: ${lambda_api}`);

            data.split('\n').forEach(function (item) {
                const arr = item.split('\t');

                if (arr && arr[0]) {
                    console.log(`body: ${arr[1]} ${arr[0]} ${arr[2]}`);

                    // post lambda api
                    request.post(`${lambda_api}`, {
                        json: {
                            ip: arr[0],
                            mac: arr[1],
                            desc: arr[2],
                            key: lambda_key
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

if (scan_shell && lambda_api) {
    job.start();
}
