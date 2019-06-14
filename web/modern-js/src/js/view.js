// Import scss files just like you would js files
import '../scss/main.scss'
import version from '../js/version/version'

const welcomeMessage = document.getElementById('welcome-message');

export default function () {
    welcomeMessage.innerHTML = 'Simple Webpack Boilerplate ' + version.get();
}
