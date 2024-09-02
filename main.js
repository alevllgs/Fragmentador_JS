const { app, BrowserWindow } = require('electron');
const path = require('path');
const { exec } = require('child_process');

function createWindow() {
    const mainWindow = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            nodeIntegration: true
        }
    });

    // Ruta al archivo app.R
    const shinyAppPath = path.join(__dirname, 'src', 'app.R');
    
    // Comando para ejecutar el servidor Shiny
    const rScriptPath = `"C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe" ${shinyAppPath}`;
    
    // Ejecutar el servidor Shiny
    exec(rScriptPath, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error al iniciar el servidor Shiny: ${error.message}`);
            return;
        }
        if (stderr) {
            console.error(`stderr: ${stderr}`);
            return;
        }
        console.log(`stdout: ${stdout}`);
    });

    // Esperar 10 segundos antes de cargar la URL para asegurar que el servidor Shiny esté listo
    setTimeout(() => {
        mainWindow.loadURL('http://127.0.0.1:4771');
    }, 10000); // Aumentado a 10 segundos
}

app.commandLine.appendSwitch('disable-gpu');

app.on('ready', createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});


