import * as json from './../../../package.json'

function get() {
    return json.version;
}

export default {
    get
}
