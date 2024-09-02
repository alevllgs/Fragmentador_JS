library(readr)  
library(readxl)
library(dplyr)
library(openxlsx)
library(zip)  # Para crear archivos ZIP

# Define el directorio base donde se encuentra la carpeta Temporal
base_dir <- getwd()

# Define la ruta del directorio Temporal dentro del directorio base
output_dir <- file.path(base_dir, "Temporal")

# Buscar el archivo CSV en la carpeta Temporal
csv_file <- list.files(output_dir, pattern = "\\.csv$", full.names = TRUE)

# Verificar si se encontró exactamente un archivo CSV
if (length(csv_file) == 1) {
  # Leer el archivo CSV
  fragmentar <- read_delim(csv_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
} else {
  stop("No se encontró un archivo CSV o hay múltiples archivos CSV en la carpeta Temporal.")
}

estab_dividir <- read_excel("src/Soporte/archivo_soporte.xlsx", 
                            sheet = "establecimientos")

selected_num_mes <- meses_es$num_mes[meses_es$Meses == selected_month]

# Filtrar y guardar los datos según cada establecimiento
for (i in 1:nrow(estab_dividir)) {
  
  # Filtrar los datos para el establecimiento actual
  datos_filtrados <- fragmentar %>% 
    filter(DESC_ESTABLECIMIENTO_SIGGES == estab_dividir$DESC_ESTABLECIMIENTO_SIGGES[i])
  
  # Crear el nombre del archivo basado en Año-Mes y nombre del establecimiento
  nombre_archivo <- paste0(selected_year, "-", selected_num_mes, "_", estab_dividir$Sigla[i]," Oportunidad del registro GES")
  
  # Definir la ruta de guardado para el archivo Excel
  excel_file <- file.path(estab_dividir$Ruta[i], paste0(nombre_archivo, ".xlsx"))
  
  # Guardar en archivo Excel
  write.xlsx(datos_filtrados, excel_file, overwrite = TRUE)
  
  # Definir la ruta del archivo ZIP usando la misma convención de nombres
  zip_file <- file.path(estab_dividir$Ruta[i], paste0(nombre_archivo, ".zip"))
  
  # Comando para crear el archivo ZIP con contraseña usando 7-Zip
  password <- "cma234tu"
  seven_zip_path <- "C:/Program Files/7-Zip/7z.exe"  # Cambia esta ruta si 7-Zip está en otro lugar
  zip_command <- sprintf('"%s" a -p%s "%s" "%s"', seven_zip_path, password, zip_file, excel_file)
  
  # Ejecutar el comando para crear el archivo ZIP con contraseña
  system(zip_command)
  
  # Eliminar el archivo Excel después de comprimirlo
  file.remove(excel_file)
  
  print(paste("Guardado y comprimido:", zip_file))
}
