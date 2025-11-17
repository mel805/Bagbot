// ==UserScript==
// @name         Discord - Colored Role Names
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Affiche les noms de rôles Discord dans leur couleur configurée
// @author       BagBot Assistant
// @match        https://discord.com/*
// @match        https://canary.discord.com/*
// @match        https://ptb.discord.com/*
// @icon         https://discord.com/assets/icon.png
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';

    console.log('🎨 Discord Colored Roles - Script chargé !');

    // Style CSS pour les rôles colorés
    const style = document.createElement('style');
    style.textContent = `
        /* Colorer les noms de rôles dans la liste des rôles */
        [class*="role_"] [class*="roleName_"],
        [class*="roleRow_"] [class*="roleName_"],
        [class*="role-"] [class*="name-"] {
            font-weight: 600 !important;
            text-shadow: 0 0 1px currentColor !important;
        }
        
        /* Animation subtile au survol */
        [class*="role_"]:hover [class*="roleName_"],
        [class*="roleRow_"]:hover [class*="roleName_"] {
            text-shadow: 0 0 8px currentColor !important;
            transition: text-shadow 0.2s ease !important;
        }
    `;
    document.head.appendChild(style);

    // Fonction pour extraire la couleur d'un élément de rôle
    function getRoleColor(roleElement) {
        // Chercher le point coloré (circle/dot) qui contient la couleur du rôle
        const colorDot = roleElement.querySelector('[class*="roleCircle"]') || 
                        roleElement.querySelector('[class*="roleDot"]') ||
                        roleElement.querySelector('[fill]');
        
        if (colorDot) {
            // Essayer d'obtenir la couleur depuis l'attribut fill (SVG)
            const fillColor = colorDot.getAttribute('fill');
            if (fillColor && fillColor !== 'currentColor') {
                return fillColor;
            }
            
            // Essayer d'obtenir la couleur depuis le style
            const bgColor = window.getComputedStyle(colorDot).backgroundColor;
            if (bgColor && bgColor !== 'rgba(0, 0, 0, 0)') {
                return bgColor;
            }
            
            // Essayer d'obtenir depuis la couleur du texte
            const color = window.getComputedStyle(colorDot).color;
            if (color) {
                return color;
            }
        }
        
        return null;
    }

    // Fonction pour appliquer la couleur au nom du rôle
    function colorizeRoleName(roleElement) {
        const roleName = roleElement.querySelector('[class*="roleName_"]') ||
                        roleElement.querySelector('[class*="name-"]');
        
        if (!roleName) return;
        
        // Éviter de recolorer si déjà fait
        if (roleName.hasAttribute('data-colored')) return;
        
        const color = getRoleColor(roleElement);
        
        if (color && color !== 'rgb(185, 187, 190)') { // Éviter le gris par défaut
            roleName.style.color = color;
            roleName.setAttribute('data-colored', 'true');
            console.log(`✅ Rôle coloré : ${roleName.textContent} → ${color}`);
        }
    }

    // Fonction pour observer et colorer tous les rôles
    function colorizeAllRoles() {
        const roleElements = document.querySelectorAll('[class*="role_"], [class*="roleRow_"]');
        
        roleElements.forEach(roleElement => {
            colorizeRoleName(roleElement);
        });
    }

    // Observer les changements du DOM pour colorer les nouveaux rôles
    const observer = new MutationObserver((mutations) => {
        let shouldUpdate = false;
        
        mutations.forEach((mutation) => {
            if (mutation.addedNodes.length > 0) {
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeType === 1) { // Element node
                        // Vérifier si c'est un rôle ou contient des rôles
                        if (node.matches && (node.matches('[class*="role_"]') || 
                            node.matches('[class*="roleRow_"]') ||
                            node.querySelector('[class*="role_"]') ||
                            node.querySelector('[class*="roleRow_"]'))) {
                            shouldUpdate = true;
                        }
                    }
                });
            }
        });
        
        if (shouldUpdate) {
            setTimeout(colorizeAllRoles, 100);
        }
    });

    // Attendre que le DOM soit prêt
    function init() {
        if (document.body) {
            // Colorer les rôles existants
            colorizeAllRoles();
            
            // Observer les changements
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
            
            console.log('✅ Discord Colored Roles - Actif !');
        } else {
            setTimeout(init, 100);
        }
    }

    // Démarrer quand le document est prêt
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Recolorer périodiquement (au cas où)
    setInterval(colorizeAllRoles, 2000);

})();
