const os = require('os'),
    ip = require('ip'),
    express = require('express'),
    request = require('request');

const exec = require('child_process').exec;
const cron = require('cron').CronJob;

const port = process.env.PORT || '3000';
const lambda_key = process.env.LAMBDA_KEY || '';
const lambda_api = process.env.LAMBDA_API || '';
const scan_shell = process.env.SCAN_SHELL || '';

const app = express();
app.set('view engine', 'ejs');
app.use(express.static('static'));

app.get('/', function (req, res) {
    let host = os.hostname();
    res.render('index.ejs', {host: host, server: ip.address()});
});

app.listen(port, function () {
    console.log(`Listening on port ${port}!`);
});

function saveJob(data) {
    data.split('\n').forEach(function (item) {
        const arr = item.split('\t');

        if (arr && arr[0]) {
            console.log(`data: ${arr[1]} ${arr[0]} ${arr[2]}`);

            const json = {
                ip: arr[0],
                mac: arr[1],
                desc: arr[2],
                beacon: lambda_key
            };

            // post lambda api
            request.post(`${lambda_api}`, {
                json: json
            }, (error, res, body) => {
                if (error) {
                    console.error(error);
                    return;
                }
                console.log(`code: ${res.statusCode}`);
                if (res.statusCode !== 200) {
                    console.error(JSON.stringify(json));
                    console.error(JSON.stringify(body));
                }
            });
        }
    });
}

function scanJob() {
    console.log(`scan start. ${date}`);

    const scan = exec(`${scan_shell}`);

    scan.stdout.on('data', data => {
        console.log(`scanned.`);
        saveJob(data);
    });

    scan.stderr.on('data', data => {
        console.error(`failure.`);
    });
}

const job = new cron({
    cronTime: '0 * * * * *',
    onTick: function() {
        scanJob();
    },
    start: false,
    timeZone: 'Asia/Seoul'
});

if (scan_shell && lambda_api) {
    console.log(`scan_shell: ${scan_shell}`);
    console.log(`lambda_api: ${lambda_api}`);

    job.start();
}
