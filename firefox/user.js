// Required for userChrome.css/userContent.css (the ShyFox theme in chrome/) to load at all.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Firefox 154+ defaults to the new native sidebar/vertical-tabs redesign, which
// breaks Sidebery's layout and the #sidebar-box-based rules in shy-sidebar.css.
// Mozilla says this stays available through end of 2026 (dev-stage control pref,
// not guaranteed long-term).
user_pref("sidebar.revamp", false);

// Firefox flips the sidebar to the right after updates; pin it to the left.
user_pref("sidebar.position_start", true);
