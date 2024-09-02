library(shiny)
library(fs)  # Para manejar archivos y directorios de manera segura

# Configura el puerto y host antes de iniciar el servidor Shiny
options(shiny.port = 4771)
options(shiny.host = "127.0.0.1")

# Aumenta el límite máximo de tamaño de archivo a, por ejemplo, 100 MB
options(shiny.maxRequestSize = 100*1024^2)

# Nombres de los meses en español
meses_es <- data.frame(
  Meses = c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
            "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"),
  num_mes = sprintf("%02d", 1:12)  # Usar sprintf para formatear los números de mes con dos dígitos
)

ui <- fluidPage(
  titlePanel("Descomprimir archivo .rar con contraseña y procesar datos"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("rarfile", "Selecciona el archivo .rar", accept = ".rar"),
      selectInput("month", "Selecciona el mes:", 
                  choices = meses_es$Meses, 
                  selected = format(Sys.Date(), "%B")),
      selectInput("year", "Selecciona el año:", 
                  choices = 2020:2025, 
                  selected = 2024),
      actionButton("unzip", "Descomprimir y Procesar")
    ),
    
    mainPanel(
      textOutput("status"),
      verbatimTextOutput("outputDir")
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$unzip, {
    req(input$rarfile)  # Asegura que un archivo haya sido seleccionado
    
    # Captura los valores seleccionados de mes y año
    selected_month <- input$month
    selected_year <- input$year
    
    # Define el directorio base donde se está ejecutando el script
    base_dir <- getwd()
    
    # Define la ruta del directorio Temporal dentro del directorio base
    output_dir <- file.path(base_dir, "Temporal")
    
    # Crea la carpeta Temporal si no existe
    if (!dir.exists(output_dir)) {
      dir.create(output_dir)
    } else {
      # Si la carpeta existe, elimina todo su contenido
      file_delete(dir_ls(output_dir))
    }
    
    # Define la ruta del archivo .rar
    rar_file <- input$rarfile$datapath
    
    # Contraseña predeterminada
    password <- "cma234tu"
    
    # Especifica la ruta completa a winrar.exe si no está en el PATH
    winrar_path <- "C:/Program Files/WinRAR/winrar.exe"
    
    # Comando para descomprimir el archivo con la contraseña proporcionada en la carpeta Temporal
    unrar_command <- sprintf('"%s" x -p%s "%s" "%s"', winrar_path, password, rar_file, output_dir)
    
    # Ejecuta el comando en el sistema
    result <- system(unrar_command, intern = TRUE)
    
    # Muestra el estado y la ruta de los archivos descomprimidos
    output$status <- renderText({
      if (length(list.files(output_dir)) > 0) {
        paste("Descompresión exitosa. Archivos descomprimidos en:", output_dir)
        
        # Ejecuta el script externo para dividir y comprimir los archivos
        source("src/02_division_establecimientos.R", local = TRUE)
        
        # Actualiza el estado después de completar el proceso
        "Proceso exitoso. La aplicación se cerrará en breve..."
      } else {
        "Error en la descomposición. Verifica el archivo."
      }
    })
    
    output$outputDir <- renderPrint({
      list.files(output_dir, full.names = TRUE)
    })
    
    # Mostrar los valores seleccionados de mes y año en la consola (opcional)
    print(paste("Mes seleccionado:", selected_month))
    print(paste("Año seleccionado:", selected_year))
    
    # Cerrar la aplicación después de un breve retraso
    invalidateLater(3000, session)
    session$onFlushed(function() {
      stopApp()
    }, once = TRUE)
  })
}

shinyApp(ui = ui, server = server)

