library(httr)
library(magrittr)

get_arq_municipio <- function(municipio) {
  
  res <- GET(
    "http://www.car.gov.br/publico/municipios/downloads"
  )
  
  GET(
    "http://www.car.gov.br/publico/municipios/captcha", 
    write_disk("captcha.png", overwrite = TRUE)
  )
  
  magick::image_read("captcha.png") %>% plot()
  arq <- decryptr::classify("captcha.png", path = "captchas/")
  captcha <- stringr::str_extract(arq, "(?<=captcha_).*(?=\\.png)")
  
  email <- "daniel@gmail.com"
  
  url <- glue::glue("http://www.car.gov.br/publico/municipios/csv?municipio%5Bid%5D={municipio}&email={email}&captcha={captcha}")
  fname <- glue::glue("data-raw/{municipio}.txt")
  GET(url, write_disk(fname, overwrite = TRUE))
  
  if(readr::read_lines(fname, n_max = 1) == "Os caracteres da imagem não foram digitados corretamente.") {
    file.remove(arq)
    cat("Tente novamente :(\n")
    get_arq_municipio(municipio)
  } else {
   cat("Uhul!\n")
   return(TRUE) 
  }
}

if (!dir.exists("data-raw"))
  dir.create("data-raw/")

if (!dir.exists("captchas"))
  dir.create("captchas/")

municipios <- readr::read_csv("data/municipios.csv")
for(i in 1:nrow(municipios)){
  get_arq_municipio(municipios$CD_GEOCMU[i])
} 
  






