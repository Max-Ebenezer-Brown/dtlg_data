## code to prepare `adsl_large`, `adsl_small`, `adae` dataset goes here
## This code can take a long time to run
library(random.cdisc.data)
library(dplyr)
library(formatters)
adsl_large <- random.cdisc.data::radsl(N=1000000)
adsl_small <- random.cdisc.data::radsl(N=20000)
adae <-random.cdisc.data::radae(adsl_small, 10L)
adae <- rbind(adae,adae,adae,adae,adae,adae,adae,adae,adae)
set.seed(99)

adae <- adae %>%
  mutate(
    AEDECOD = with_label(as.character(AEDECOD), "Dictionary-Derived Term"),
    AESDTH = with_label(
      sample(c("N", "Y"), size = nrow(adae), replace = TRUE, prob = c(0.99, 0.01)),
      "Results in Death"
    ),
    AEACN = with_label(
      sample(
        c("DOSE NOT CHANGED", "DOSE INCREASED", "DRUG INTERRUPTED", "DRUG WITHDRAWN"),
        size = nrow(adae),
        replace = TRUE, prob = c(0.68, 0.02, 0.25, 0.05)
      ),
      "Action Taken with Study Treatment"
    ),
    FATAL = with_label(AESDTH == "Y", "AE with fatal outcome"),
    SEV = with_label(AESEV == "SEVERE", "Severe AE (at greatest intensity)"),
    SER = with_label(AESER == "Y", "Serious AE"),
    SERWD = with_label(AESER == "Y" & AEACN == "DRUG WITHDRAWN", "Serious AE leading to withdrawal from treatment"),
    SERDSM = with_label(
      AESER == "Y" & AEACN %in% c("DRUG INTERRUPTED", "DOSE INCREASED", "DOSE REDUCED"),
      "Serious AE leading to dose modification/interruption"
    ),
    RELSER = with_label(AESER == "Y" & AEREL == "Y", "Related Serious AE"),
    WD = with_label(AEACN == "DRUG WITHDRAWN", "AE leading to withdrawal from treatment"),
    DSM = with_label(
      AEACN %in% c("DRUG INTERRUPTED", "DOSE INCREASED", "DOSE REDUCED"), "AE leading to dose modification/interruption"
    ),
    REL = with_label(AEREL == "Y", "Related AE"),
    RELWD = with_label(AEREL == "Y" & AEACN == "DRUG WITHDRAWN", "Related AE leading to withdrawal from treatment"),
    RELDSM = with_label(
      AEREL == "Y" & AEACN %in% c("DRUG INTERRUPTED", "DOSE INCREASED", "DOSE REDUCED"),
      "Related AE leading to dose modification/interruption"
    ),
    CTC35 = with_label(AETOXGR %in% c("3", "4", "5"), "Grade 3-5 AE"),
    CTC45 = with_label(AETOXGR %in% c("4", "5"), "Grade 4/5 AE"),
    USUBJID_AESEQ = paste(USUBJID, AESEQ, sep = "@@") # Create unique ID per AE in dataset.
  ) %>%
  filter(ANL01FL == "Y")

save(adsl_large,file = 'adsl_large.rda')
save(adsl_small,file = 'adsl_small.rda')
save(adae,file = 'adae.rda')
