# Clean population and gdpk data
# Lutfi Sun
# April 2 2021

library(readr)
library(tidyverse)

##### population district to province

pop_district <- read_csv("../data/population_district.csv")

pop_district$province <-tolower(pop_district$province)

pop_long <- pop_district %>% gather(year, population, -c(province, district))

pop_province <- pop_long %>% 
  group_by(year, province) %>%
  summarize(population=sum(population))

##### merge with incarceration

turkey_convicts <- read_csv("../data/turkey_convicts_gdpk.csv")

turkey_convicts$province <-  tolower(turkey_convicts$province)

turkey_convicts2 <- merge(pop_province, turkey_convicts,
                          by = c("year","province"),
                          all = TRUE)

turkey_convicts2 <- turkey_convicts2 %>% 
  mutate( population = ifelse(is.na(population), pop_total, population)) %>%
  select(-c(pop_total))

##### merge with nightlight gdpk estimates

nightest <- read_csv("../data/gdpk_nightest.csv")
nightest$province <-tolower(nightest$province)
nightest <- nightest %>% gather(year, gdpkk, -c(province))

turkey_convicts3 <- merge(turkey_convicts2, nightest,
                          by = c("year","province"),
                          all = TRUE)

turkey_convicts3 <- turkey_convicts3 %>% 
  mutate( gdpk = ifelse(is.na(gdpk), gdpkk, gdpk)) %>%
  select(-c(gdpkk))


##### 
# merge with election, divorce, and suicide data

election <- read_csv("../data/elections_suicides.csv")

election <- election %>% select(-c(province))

turkey_convicts4 <- merge(turkey_convicts3, election,
                          by = c("year","region_code"),
                          all = TRUE)
names(turkey_convicts4)

library(zoo)
length( turkey_convicts4$akp_gen)

turkey_convicts4$vs_akp <- na.locf(turkey_convicts4$akp_gen, fromLast = TRUE, na.rm = FALSE)
turkey_convicts4$vs_chp <- na.locf(turkey_convicts4$chp_gen, fromLast = TRUE, na.rm = FALSE)
turkey_convicts4$vs_mhp <- na.locf(turkey_convicts4$mhp_gen, fromLast = TRUE, na.rm = FALSE)
turkey_convicts4$vs_hdp <- na.locf(turkey_convicts4$hdp_gen, fromLast = TRUE, na.rm = FALSE)

turkey_convicts4 <- turkey_convicts4 %>% 
  mutate( ms_akp = akp_loc / loc_mayors, 
          ms_chp = chp_loc / loc_mayors, 
          ms_mhp = mhp_loc / loc_mayors)

turkey_convicts4$ms_akp <- na.locf(turkey_convicts4$ms_akp, fromLast = TRUE, na.rm = FALSE)
turkey_convicts4$ms_chp <- na.locf(turkey_convicts4$ms_chp, fromLast = TRUE, na.rm = FALSE)
turkey_convicts4$ms_mhp <- na.locf(turkey_convicts4$ms_mhp, fromLast = TRUE, na.rm = FALSE)

#####


##### 
# clean education data and merge

educ_all <- read_csv("../data/educ_all.csv")

educ_all$province <- tolower(educ_all$province)
educ_all$province <- gsub("ğ", "g", educ_all$province)
educ_all$province <- gsub("ç", "c", educ_all$province)
educ_all$province <- gsub('ı', 'i', educ_all$province)
educ_all$province <- gsub("ö", "o", educ_all$province)
educ_all$province <- gsub("ş", "s", educ_all$province)
educ_all$province <- gsub("ü", "u", educ_all$province)

turkey_convicts5 <- merge(turkey_convicts4, educ_all,
                          by = c("year","province"),
                          all = TRUE)


######
# add regions

akdeniz <- c("antalya", "burdur", "isparta", "mersin", 
             "adana", "hatay", "osmaniye", "kahramanmaras")

dogu <- c("malatya", "erzincan", "elazig", "tunceli", "bingol", "erzurum", "mus", 
          "bitlis", "sirnak", "kars", "agri", "ardahan", "van", "igdir", "hakkari")

ege <- c("izmir", "aydin", "mugla", "manisa", "denizli", "usak", 
         "kutahya", "afyonkarahisar")

guneydogu <- c("gaziantep", "kilis", "adiyaman", "sanliurfa", "diyarbakir", 
               "mardin", "batman", "siirt")

icanadolu <- c("eskisehir", "konya", "ankara", "cankiri", "aksaray", "kirikkale", 
               "kirsehir", "yozgat", "nigde", "nevsehir", "kayseri", "karaman", "sivas")

karadeniz <- c("bolu", "duzce", "zonguldak", "karabuk", "bartin", "kastamonu", "corum", 
               "sinop", "samsun", "amasya", "tokat", "ordu", "giresun", "gumushane", 
               "trabzon", "bayburt", "rize", "artvin")

marmara <- c("canakkale", "balikesir", "edirne", "tekirdag", "kirklareli", "istanbul", 
             "bursa", "yalova", "kocaeli", "bilecik", "sakarya")


turkey_convicts5$region <- NA

for (i in 1:1620) {
  if (turkey_convicts5$province[i] %in% akdeniz) {
    turkey_convicts5$region[i] <- "akdeniz"
  }
  else if (turkey_convicts5$province[i] %in% dogu) {
    turkey_convicts5$region[i] <- "dogu"
  }
  else if (turkey_convicts5$province[i] %in% ege) {
    turkey_convicts5$region[i] <- "ege"
  }
  else if (turkey_convicts5$province[i] %in% guneydogu) {
    turkey_convicts5$region[i] <- "guneydogu"
  }
  else if (turkey_convicts5$province[i] %in% icanadolu) {
    turkey_convicts5$region[i] <- "icanadolu"
  }
  else if (turkey_convicts5$province[i] %in% karadeniz) {
    turkey_convicts5$region[i] <- "karadeniz"
  }
  else if (turkey_convicts5$province[i] %in% marmara) {
    turkey_convicts5$region[i] <- "marmara"
  }
}

write_csv(turkey_convicts5, '../data/turkey_convicts_mid.csv')




