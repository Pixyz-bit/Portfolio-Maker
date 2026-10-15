const fs=require('fs'),path=require('path');
const root=path.resolve('241611JalopPersonalWebsite');
function walk(p){return fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()&&!['bin','obj','.vs'].includes(e.name)?walk(path.join(p,e.name)):e.isFile()?[path.join(p,e.name)]:[])}
let files=walk(root),source=files.filter(x=>/\.(cs|aspx|ascx|js|css|sql|config|csproj)$/.test(x));
let xml=fs.readFileSync(path.join(root,'241611JalopPersonalWebsite.csproj'),'utf8');
let included=[...xml.matchAll(/(?:Content|Compile|None) Include="([^"]+)"/g)].map(m=>m[1]);
let result={files:files.length,sourceFiles:source.length,sourceBytes:source.reduce((n,p)=>n+fs.statSync(p).size,0),missingIncludes:included.filter(p=>!fs.existsSync(path.join(root,p))),unlistedImages:files.filter(p=>p.includes('Uploads')&&!included.includes(path.relative(root,p))).map(p=>path.relative(root,p)),fonts:files.filter(p=>p.endsWith('.woff2')).map(p=>({name:path.basename(p),validHeader:fs.readFileSync(p).subarray(0,4).toString()==='wOF2'}))};
fs.writeFileSync('Tests/Temp/final-inventory.json',JSON.stringify(result,null,2));
console.log(JSON.stringify(result));
