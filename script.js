// ===== Branch data =====
// Format: "NAME<TAB>lat,lon" per line
const RAW = `NMSPL HAVERI BRANCH\t14.78913889,75.3961389
NMSPL KAGAL BRANCH\t16.5743675,74.3125155
NMSPL MYSORE BRANCH\t12.31402778,76.69172222
NMSPL KOLHAPUR BRANCH\t16.7009134,74.2298802
NMSPL GADHINGLAJ BRANCH\t16.2360688,74.2615105
NMSPL SANGLI BRANCH\t16.8641977,74.5529161
NMSPL SOLHAPUR BRANCH\t17.6791231,75.9412751
NMSPL TASGOAN BRANCH\t17.0250976,74.6080964
NMSPL MANGALWEDHA BRANCH\t17.5201002,75.4516932
NMSPL NYAMATHI BRANCH\t14.1540464,75.5739136
NMSPL K R NAGAR BRANCH\t12.43944444,76.3815
NMSPL KOLLEGALA BRANCH\t12.15975,77.10491667
NMSPL H D KOTE BRANCH\t12.08066667,76.33733333
NMSPL K R PETE BRANCH\t12.66369444,76.48411111
NMSPL HOLENARASIPURA BRANCH\t12.78355556,76.24636111
NMSPL T NARASIPURA BRANCH\t12.20694444,76.89866667
NMSPL SRIRANGAPATTANA BRANCH\t12.42036111,76.69102778
NMSPL KANAKAPURA BRANCH\t12.54444444,77.42894444
NMSPL HASSAN BRANCH\t13.01669444,76.11227778
NMSPL HUNSUR BRANCH\t12.29919444,76.29072222
NMSPL BELLUR CROSS BRANCH\t12.95994444,76.7445
NMSPL CHANNARAYAPATTANA BRANCH\t12.90158333,76.38858333
NMSPL CHHINDWARA BRANCH\t22.033789,78.92971
NMSPL BICCHUA BRANCH\t21.81433333,79.03947222
NMSPL JUNNARDEO BRANCH\t22.18661111,78.59613889
NMSPL CHHAPARA BRANCH\t22.39783333,79.54591667
NMSPL KATANGI BRANCH\t21.75955556,79.79638889
NMSPL KHATEGAON BRANCH\t22.5887633,76.9256849
NMSPL NARMADAPURAM BRANCH\t22.74844444,77.74041667
NMSPL PIRIYAPATHNA BRANCH\t12.3372231,76.0898843
NMSPL MALAVALLI BRANCH\t12.3842962,77.0584043
NMSPL SANTEMARALLI BRANCH\t12.0443668,76.9798562
NMSPL GUNDLUPETE BRANCH\t11.81872222,76.684
NMSPL ANNUR BRANCH\t11.23241667,77.09672222
NMSPL ANTHIYUR BRANCH\t11.57111111,77.59094444
NMSPL TIRUCHANGODE BRANCH\t11.38627778,77.89425
NMSPL ILLUPUR BRANCH\t10.51230556,78.62177778
NMSPL UDUMALPET BRANCH\t10.59508333,77.24563889
NMSPL ALANGAYAM BRANCH\t12.62116667,78.74961111
NMSPL ARANI BRANCH\t12.67627778,79.28691667
NMSPL CHENGAM BRANCH\t12.307923,78.7928836
NMSPL DEKNIKOTE BRANCH\t12.53147222,77.78983333
NMSPL GUDIYATHAM BRANCH\t12.94502778,78.87630556
NMSPL KRISHNAGIRI BRANCH\t12.52313889,78.21719444
NMSPL METTUR BRANCH\t11.78005556,77.80830556
NMSPL NATRAMPALLI BRANCH\t12.5896672,78.5108759
NMSPL PALACODE BRANCH\t12.29627778,78.07441667
NMSPL SHOLINGHUR BRANCH\t13.1023922,79.4197245
NMSPL NIRMAL BRANCH\t19.0835,78.35455556
NMSPL RAJAMPET BRANCH\t14.18902778,79.16572222
NMSPL NELLORE BRANCH\t14.4032098,79.9510029
NMSPL SHIMOGGA BRANCH\t13.92791667,75.59122222
NMSPL SHIKARIPURA BRANCH\t14.27225,75.35638889
NMSPL RANEBENNUR BRANCH\t14.61269444,75.63694444
NMSPL RAMANAGARA BRANCH\t12.72808333,77.27447222
NMSPL MANDYA BRANCH\t12.51705556,76.89605556
NMSPL BELUR BRANCH\t13.16616667,75.86447222
NMSPL ARAKALAGUDU BRANCH\t12.77013889,76.05530556
NMSPL HIREKERUR BRANCH\t14.45586111,75.39169444
NMSPL ANAVATTI BRANCH\t14.55669444,75.15602778
NMSPL MAGADI BRANCH\t12.95730556,77.22277778
NMSPL AKKAIALUR BRANCH\t14.72708333,75.1695
NMSPL BYADAGI BRANCH\t14.67558333,75.48594444
NMSPL SHIGGON BRANCH\t14.98988889,75.21841667
NMSPL MUNDGOD BRANCH\t14.9721983,75.0379143
NMSPL GUTTAL BRANCH\t14.8392801,75.6274997
NMSPL HONNAVAR BRANCH\t14.28233333,74.44875`;

// ===== Helpers =====
const d = (v, p=6) => Number(v).toFixed(p);
const gmUrl = (lat, lon) => `https://www.google.com/maps?q=${lat},${lon}`;

function parseDMS(dmsStr) {
  const re = /(\\d+)°(\\d+)'([\\d.]+)\"([NS])\\s+(\\d+)°(\\d+)'([\\d.]+)\"([EW])/;
  const m = dmsStr.match(re);
  if (!m) return null;
  const [_, d1, m1, s1, h1, d2, m2, s2, h2] = m;
  const lat = (Number(d1) + Number(m1)/60 + Number(s1)/3600) * (h1 === 'S' ? -1 : 1);
  const lon = (Number(d2) + Number(m2)/60 + Number(s2)/3600) * (h2 === 'W' ? -1 : 1);
  return { lat, lon };
}

function parseRaw(raw) {
  return raw.split(/\\n+/)
    .map(line => line.trim())
    .filter(Boolean)
    .map(line => {
      if (line.includes('°')) {
        const m = line.match(/^(.*?)\\s*(\\d+°\\d+'[\\d.]+\"[NS]\\s+\\d+°\\d+'[\\d.]+\"[EW])/);
        if (m) {
          const name = m[1].trim();
          const coords = parseDMS(m[2]);
          if (coords) return { name, lat: coords.lat, lon: coords.lon };
        }
      }
      const m2 = line.match(/^(.*?)([-+]?\\d+(?:\\.\\d+)?)\\s*,\\s*([-+]?\\d+(?:\\.\\d+)?)/);
      if (m2) {
        const name = m2[1].trim().replace(/\\s+$/,'');
        const lat = Number(m2[2]);
        const lon = Number(m2[3]);
        return { name, lat, lon };
      }
      return null;
    })
    .filter(Boolean);
}

const rows = parseRaw(RAW);

// ===== Map =====
let map, markersLayer;
function initMap() {
  map = L.map('map', { scrollWheelZoom: true });
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);
  markersLayer = L.layerGroup().addTo(map);
  updateMarkers('');
}

function updateMarkers(filter) {
  markersLayer.clearLayers();
  const filtered = rows.filter(r => r.name.toLowerCase().includes(filter.toLowerCase()));
  const bounds = [];
  filtered.forEach(r => {
    const marker = L.marker([r.lat, r.lon])
      .bindPopup(`<strong>${r.name}</strong><br/>(${d(r.lat)}, ${d(r.lon)})<br/><a href="${gmUrl(r.lat, r.lon)}" target="_blank" rel="noopener">Open in Google Maps</a>`)
      .on('click', () => window.open(gmUrl(r.lat, r.lon), '_blank'));
    marker.addTo(markersLayer);
    bounds.push([r.lat, r.lon]);
  });
  if (bounds.length) {
    map.fitBounds(bounds, { padding: [30, 30] });
  } else {
    map.setView([15.5, 76.5], 6);
  }
}

// ===== Table =====
const tbody = document.querySelector('#tbl tbody');
const countEl = document.getElementById('count');

function render(filter = '') {
  tbody.innerHTML = '';
  const filtered = rows.filter(r => r.name.toLowerCase().includes(filter.toLowerCase()));
  let i = 0;
  filtered.forEach((r) => {
    const tr = document.createElement('tr');

    const n = document.createElement('td');
    n.className = 'num';
    n.textContent = (++i).toString();

    const name = document.createElement('td');
    name.className = 'name';
    const aName = document.createElement('a');
    aName.href = gmUrl(r.lat, r.lon);
    aName.target = '_blank';
    aName.rel = 'noopener';
    aName.textContent = r.name;
    aName.style.color = '#bfe1ff';
    aName.style.textDecoration = 'none';
    name.appendChild(aName);

    const coords = document.createElement('td');
    coords.className = 'coords';
    const aCoords = document.createElement('a');
    aCoords.href = gmUrl(r.lat, r.lon);
    aCoords.target = '_blank';
    aCoords.rel = 'noopener';
    aCoords.textContent = `(${d(r.lat)}, ${d(r.lon)})`;
    coords.appendChild(aCoords);

    const actions = document.createElement('td');
    actions.className = 'actions';
    const btn = document.createElement('a');
    btn.className = 'btn';
    btn.href = gmUrl(r.lat, r.lon);
    btn.target = '_blank';
    btn.rel = 'noopener';
    btn.textContent = 'Open in Maps';
    actions.appendChild(btn);

    tr.append(n, name, coords, actions);
    tbody.appendChild(tr);
  });
  countEl.textContent = `${filtered.length} shown of ${rows.length} branches`;

  if (map) updateMarkers(filter);
}

// Search + controls
const search = document.getElementById('search');
const clearBtn = document.getElementById('clearBtn');
const copyBtn = document.getElementById('copyBtn');
const fitBtn = document.getElementById('fitBtn');
const locateBtn = document.getElementById('locateBtn');

search.addEventListener('input', () => render(search.value));
clearBtn.addEventListener('click', () => { search.value = ''; render(''); });

copyBtn.addEventListener('click', () => {
  const visible = Array.from(document.querySelectorAll('#tbl tbody tr')).map(tr => {
    const name = tr.children[1].innerText.trim();
    const coordTxt = tr.children[2].innerText.replace(/[()]/g,'').trim();
    return `${name},${coordTxt}`;
  }).join('\\n');
  navigator.clipboard.writeText(visible).then(() => {
    copyBtn.textContent = 'Copied!';
    setTimeout(()=> copyBtn.textContent = 'Export CSV', 1200);
  });
});

fitBtn.addEventListener('click', () => updateMarkers(search.value));

locateBtn.addEventListener('click', () => {
  if (!navigator.geolocation) return alert('Geolocation not supported');
  navigator.geolocation.getCurrentPosition(pos => {
    const { latitude: lat, longitude: lon } = pos.coords;
    L.circleMarker([lat, lon], { radius: 6 }).addTo(map).bindPopup('You are here');
    map.setView([lat, lon], 12);
  }, err => alert('Location failed: ' + err.message), { enableHighAccuracy: true, timeout: 8000 });
});

// Initial render + map
render('');
initMap();
