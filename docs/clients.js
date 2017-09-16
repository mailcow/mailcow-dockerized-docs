if (window.location.href.indexOf('/client/') >= 0) {
    window.window.addEventListener('load', function () {
        function getParameterByName(name) {
            var match = RegExp('[?#&]' + name + '=([^&]*)').exec(window.location.hash);
            return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
        }
    
        /* Store URL variables in cookies */
        if (getParameterByName('host')) {
            document.cookie = "host=" + getParameterByName('host') + "; path=/";
        }
        if (getParameterByName('email')) {
            var email = getParameterByName('email');
            document.cookie = "email=" + email + "; path=/";
            document.cookie = "domain=" + email.substring(email.indexOf('@') + 1) + "; path=/";
        }
        if (getParameterByName('name')) {
            document.cookie = "name=" + getParameterByName('name') + "; path=/";
        }
        if (getParameterByName('port')) {
            document.cookie = "port=" + getParameterByName('port') + "; path=/";
        }
        if (getParameterByName('integrator')) {
            document.cookie = "integrator=" + getParameterByName('integrator') + "; path=/";
        }
        if (getParameterByName('outlookEAS')) {
            document.cookie = "outlookEAS=" + getParameterByName('outlookEAS') + "; path=/";
        }
    });
}

if (window.location.href.indexOf('/client') >= 0) {
    window.window.addEventListener('load', function () {
        function getCookie(cn) {
            var cs = document.cookie.split(';');
            for (var i = 0; i < cs.length; i++) {
                var c = cs[i];
                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(cn + "=") == 0) {
                    return c.substring(cn.length + 1, c.length);
                }
            }
            return "";
        }
    
        /* Hide variable fields if no values are available */
        if (!getCookie('host')) {
            Array.prototype.forEach.call(document.getElementsByClassName('client_variables_available'), function(el) {
                el.style.display = 'none';
            });
        } else {
            Array.prototype.forEach.call(document.getElementsByClassName('client_variables_unavailable'), function(el) {
                el.style.display = 'none';
            });
        }
    
        /* Hide the TOC, which might contain hidden content */
        Array.prototype.forEach.call(document.getElementsByClassName('md-sidebar--secondary'), function(el) {
            el.style.display = 'none';
        });
    
        /* Substitute variables */
        Array.prototype.forEach.call(document.getElementsByClassName('client_var_host'), function(el) {
            el.innerText = getCookie('host');
        });
        Array.prototype.forEach.call(document.getElementsByClassName('client_var_link'), function(el) {
            if (!getCookie('host')) {
                el.href = '#';
            } else if (getCookie('port') != '443') {
                el.href = 'https://' + getCookie('host') + ':' + getCookie('port') + '/' + el.getAttribute("href");
            } else {
                el.href = 'https://' + getCookie('host') + '/' + el.getAttribute("href");
            }
        });
        Array.prototype.forEach.call(document.getElementsByClassName('client_var_email'), function(el) {
            el.innerText = getCookie('email');
        });
        Array.prototype.forEach.call(document.getElementsByClassName('client_var_name'), function(el) {
            el.innerText = getCookie('name');
        });
        if (getCookie('port') != '443') {
            Array.prototype.forEach.call(document.getElementsByClassName('client_var_port'), function(el) {
                el.innerText = ':' + getCookie('port');
            });
        }
    
        /* Hide those sections that are not applicable because useOutlookForEAS is disabled or SOGo integrator is not available */
        if (getCookie('integrator')) {
            Array.prototype.forEach.call(document.getElementsByClassName('client_var_integrator_link'), function(el) {
                el.href = el.href.replace('__DOMAIN__', getCookie('domain')).replace('__VERSION__', getCookie('integrator'));
            });
            Array.prototype.forEach.call(document.getElementsByClassName('client_integrator_disabled'), function(el) {
                el.style.display = 'none';
            });
        } else if (getCookie('host')) {
            Array.prototype.forEach.call(document.getElementsByClassName('client_integrator_enabled'), function(el) {
                el.style.display = 'none';
            });
        }
        if (getCookie('outlookEAS') || !getCookie('host')) {
            Array.prototype.forEach.call(document.getElementsByClassName('client_outlookEAS_disabled'), function(el) {
                el.style.display = 'none';
            });
        } else {
            Array.prototype.forEach.call(document.getElementsByClassName('client_outlookEAS_enabled'), function(el) {
                el.style.display = 'none';
            });
        }
    });
}
