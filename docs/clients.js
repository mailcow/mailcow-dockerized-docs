if (window.location.href.indexOf('/client/') >= 0) {
    window.window.addEventListener('load', function () {
        function setCookie(name, value) {
            document.cookie = encodeURIComponent(name) + "=" + encodeURIComponent(value) + "; path=/";
        }

        function getParameterByName(name) {
            var match = RegExp('[?#&]' + name + '=([^&]*)').exec(window.location.hash);
            return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
        }

        /* Store URL variables in cookies */
        if (getParameterByName('host')) {
            setCookie("host", getParameterByName('host'));
        }
        if (getParameterByName('email')) {
            var email = getParameterByName('email');
            setCookie("email", email);
            setCookie("domain", email.substring(email.indexOf('@') + 1));
        }
        if (getParameterByName('name')) {
            setCookie("name", getParameterByName('name'));
        }
        if (getParameterByName('ui')) {
            setCookie("ui", getParameterByName('ui'));
        }
        if (getParameterByName('port')) {
            setCookie("port", getParameterByName('port'));
        }
        if (getParameterByName('integrator')) {
            setCookie("integrator", getParameterByName('integrator'));
        }
        if (getParameterByName('outlookEAS')) {
            setCookie("outlookEAS", getParameterByName('outlookEAS'));
        }
    });
}

if (window.location.href.indexOf('/client') >= 0) {
    window.window.addEventListener('load', function () {
        function getCookie(cn) {
            var fixedcn = encodeURIComponent(cn);
            var cs = document.cookie.split(';');
            for (var i = 0; i < cs.length; i++) {
                var c = cs[i];
                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(fixedcn + "=") == 0) {
                    return decodeURIComponent(c.substring(cn.length + 1, c.length));
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
            if (!getCookie('ui') && !getCookie('host')) {
                el.href = '#';
            } else {
                var ui_domain = getCookie('ui') ? getCookie('ui') : getCookie('host');
                if (getCookie('port') != '443') {
                    el.href = 'https://' + ui_domain + ':' + getCookie('port') + '/' + el.getAttribute("href");
                } else {
                    el.href = 'https://' + ui_domain + '/' + el.getAttribute("href");
                }
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
