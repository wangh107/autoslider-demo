library(autoslider.core)
library(dplyr)
spec_file <- "specs.yml"
filters <- "filters.yml"
filters::load_filters(filters, overwrite = TRUE)
# read data
data <- list(
  "adsl" = eg_adsl %>%
    mutate(
      FASFL = SAFFL,  
      DISTRTFL = sample(c("Y", "N"), size = length(TRT01A), replace = TRUE, prob = c(.1, .9))
    ) %>%
    preprocess_t_ds(), # this preproccessing is required by one of the autoslider.core functions
  "adae" = eg_adae,
  "adtte" = eg_adtte,
  "adrs" = eg_adrs,
  "adlb" = eg_adlb
)

# create outputs based on the specs and the functions
outputs <- spec_file %>%
  read_spec() %>%  
  # generate_outputs function requires the data and spec
  generate_outputs(datasets = data) %>%
  # now we decorate based on the specs, i.e. add footnotes and titles
  decorate_outputs(
    version_label = NULL
  )

outputs %>%
  generate_slides(
    outfile = "outputs/demo.pptx",
    template = file.path(system.file(package = "autoslider.core"), "/theme/basic.pptx"),
    table_format = autoslider_format
  )


prompt_list <- get_prompt_list("prompt.yml")
outputs <-  spec_file %>%
  read_spec() %>%
  # we can also filter for specific programs, if we don't want to create them all
  filter_spec(., program %in% c("t_ds_slide")) %>%
  generate_outputs(datasets = data) %>%
  decorate_outputs()

outputs_ai <- get_ai_notes(
  outputs = outputs, 
  prompt_list = prompt_list, 
  platform = "ollama",
  base_url = "http://localhost:11434",
  model = "llama3.2:1b"
)
outputs_ai %>%
  generate_slides(outfile = "outputs/demo_AI.pptx")
