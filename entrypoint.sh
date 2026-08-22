#!/bin/sh

# Create VNC config directory
mkdir -p "${HOME}/.vnc"

# Generate the xstartup script
cat > "${HOME}/.vnc/xstartup" << 'EOF'
#!/bin/sh
dbus-launch --sh-syntax > /dev/null 2>&1
xsetroot -solid '#282828' &
st &
exec dwm
EOF
chmod +x "${HOME}/.vnc/xstartup"

# Start the TigerVNC server in the foreground
if [ -n "${VNC_PASSWORD}" ]; then
    echo "${VNC_PASSWORD}" | vncpasswd -f > "${HOME}/.vnc/passwd"
    chmod 600 "${HOME}/.vnc/passwd"
    exec vncserver :0 -fg \
        -geometry "${GEOMETRY}" \
        -depth "${DEPTH}" \
        -dpi "${DPI}" \
        -localhost no \
        -SecurityTypes VncAuth \
        -PasswordFile "${HOME}/.vnc/passwd" \
        -xstartup "${HOME}/.vnc/xstartup"
else
    exec vncserver :0 -fg \
        -geometry "${GEOMETRY}" \
        -depth "${DEPTH}" \
        -dpi "${DPI}" \
        -localhost no \
        -SecurityTypes None \
        --I-KNOW-THIS-IS-INSECURE \
        -xstartup "${HOME}/.vnc/xstartup"
fi
