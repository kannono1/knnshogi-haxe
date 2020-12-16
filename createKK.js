console.log('createKK::start');
const fs = require("fs");
// fs.open('bin/KK_synthesized.bin', 'r', (err, fd) => {
//     if(err) throw err;
//     const buff = Buffer.alloc(256);
//     console.log('read OK');
//     fs.read(fd, buff, 0, 256, 0, (err, bytesRead, buffer) => {
//         if(err) throw err;
//         console.log(buffer);

//         fs.close(fd, (err) => {
//             if(err) throw err;
//         })
//     })
// });
const stream = fs.createReadStream('bin/KK_synthesized.bin', {
    highWaterMark: 4
});
// [81][81][2] Int32(4byte)
let count = 0;
let i, j, k;
stream.on("readable", () => {
    let chunk;
    while( (chunk = stream.read()) !== null ) {
        i = parseInt((count/2) /81);
        j = parseInt(count/2) %81;
        k = count %2;
        v = chunk.readInt32LE(0, false);
        // console.log(chunk.toString('utf8'));
        console.log(i, j, k, v);
        count++;
    }
    console.log(`count:${count}`);
})