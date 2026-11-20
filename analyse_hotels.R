# =============================================================================
# Projet sommatif UA2 - Analyse exploratoire des données (AED)
# Réservations hôtelières
# Équipe : Safaa Naamane, Fatima Zohra Aboudeine
#
# Prérequis : placer hotels.csv à la racine du projet (voir README.md)
# Exécution : source("analyse_hotels.R") ou ouvrir dans RStudio
# Les figures sont enregistrées dans le dossier figures/
# =============================================================================

library(tidyverse)

dir.create("figures", showWarnings = FALSE)

sauver <- function(nom, largeur = 7, hauteur = 4.5) {
  ggsave(file.path("figures", nom), width = largeur, height = hauteur, dpi = 150)
}

# =============================================================================
# ÉTAPE 1 - Comprendre le jeu de données
# =============================================================================

hotels <- read.csv("hotels.csv", stringsAsFactors = FALSE)

# Q1 - Structure et unité d'observation
dim(hotels)
glimpse(hotels)
summary(hotels)
table(sapply(hotels, class))
table(hotels$arrival_date_year, hotels$arrival_date_month)
table(hotels$hotel)

# Q2 - Nature des variables
str(hotels)
sapply(hotels, n_distinct)

# Q3 - Qualité des données
colSums(is.na(hotels))
sum(hotels$country == "NULL")
sum(hotels$agent == "NULL")
sum(hotels$company == "NULL")
sum(duplicated(hotels))
sum(hotels$adults + hotels$children + hotels$babies == 0, na.rm = TRUE)
sum(hotels$stays_in_weekend_nights + hotels$stays_in_week_nights == 0)
sum(hotels$stays_in_weekend_nights + hotels$stays_in_week_nights > 30)
sum(hotels$adr < 0); sum(hotels$adr == 0); max(hotels$adr)
sum(hotels$lead_time > 365); sum(hotels$adults > 10)
table(hotels$reservation_status, hotels$is_canceled)

# Q4 - Dictionnaire des variables utilisées
hotels |>
  select(hotel, is_canceled, lead_time, adr, arrival_date_month) |>
  glimpse()

# Q5 - Copie d'analyse (nettoyage)
h <- hotels |>
  mutate(
    children = replace_na(children, 0),
    country = na_if(country, "NULL"),
    adr = if_else(adr < 0, NA_real_, adr),
    arrival_date_month = factor(arrival_date_month, levels = month.name, ordered = TRUE),
    reservation_status_date = as.Date(reservation_status_date),
    hotel = factor(hotel)
  )

sum(is.na(h$adr))                      # 1
sum(is.na(h$reservation_status_date))  # 0

# =============================================================================
# ÉTAPE 2 - Plan d'analyse (voir le rapport)
# =============================================================================

# =============================================================================
# ÉTAPE 3 - Distributions univariées
# =============================================================================

# Q2 - Variables quantitatives
summary(h$lead_time)
sd(h$lead_time)
summary(h$adr)
sd(h$adr, na.rm = TRUE)

# Valeurs atypiques (règle de l'IQR)
iqr_lead_time       <- IQR(h$lead_time, na.rm = TRUE)
q3_lead_time        <- quantile(h$lead_time, 0.75, na.rm = TRUE)
borne_sup_lead_time <- q3_lead_time + 1.5 * iqr_lead_time
sum(h$lead_time > borne_sup_lead_time, na.rm = TRUE)

iqr_adr       <- IQR(h$adr, na.rm = TRUE)
q3_adr        <- quantile(h$adr, 0.75, na.rm = TRUE)
borne_sup_adr <- q3_adr + 1.5 * iqr_adr
sum(h$adr > borne_sup_adr, na.rm = TRUE)

# Figure 3.1
ggplot(h, aes(lead_time)) +
  geom_histogram(binwidth = 10, fill = "steelblue") +
  labs(title = "Distribution des délais de réservation",
       x = "Délai de réservation (jours)", y = "Nombre de réservations") +
  theme_minimal()
sauver("fig_3_1_hist_lead_time.png")

# Figure 3.2
ggplot(h, aes(adr)) +
  geom_histogram(binwidth = 10, fill = "steelblue") +
  coord_cartesian(xlim = c(0, 300)) +
  labs(title = "Distribution des tarifs journaliers (0 à 300)",
       x = "Tarif journalier moyen (ADR)", y = "Nombre de réservations") +
  theme_minimal()
sauver("fig_3_2_hist_adr.png")

# Q3 - Variables qualitatives
h |> count(hotel) |> mutate(prop = n / sum(n))
h |> count(is_canceled) |> mutate(prop = n / sum(n))

# Figure 3.3
ggplot(h, aes(hotel)) + geom_bar(fill = "steelblue") +
  labs(title = "Répartition des réservations par type d'hôtel",
       x = "Type d'hôtel", y = "Nombre de réservations") +
  theme_minimal()
sauver("fig_3_3_hotel.png")

# Figure 3.4
ggplot(h, aes(factor(is_canceled, labels = c("Non annulée", "Annulée")))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Répartition des réservations selon l'annulation",
       x = "Statut d'annulation", y = "Nombre de réservations") +
  theme_minimal()
sauver("fig_3_4_annulation.png")

# =============================================================================
# ÉTAPE 4 - Relations entre les variables
# =============================================================================

# --- Comparaison 1 : ADR selon le type d'hôtel -------------------------------
h |>
  group_by(hotel) |>
  summarise(
    n   = sum(!is.na(adr)),
    moy = mean(adr, na.rm = TRUE),
    med = median(adr, na.rm = TRUE),
    et  = sd(adr, na.rm = TRUE),
    min = min(adr, na.rm = TRUE),
    max = max(adr, na.rm = TRUE)
  )

# Figure 4.1
ggplot(h, aes(hotel, adr)) +
  geom_boxplot(fill = "steelblue") +
  coord_cartesian(ylim = c(0, 300)) +
  labs(title = "Distribution des tarifs selon le type d'hôtel",
       x = "Type d'hôtel", y = "Tarif journalier moyen (ADR)") +
  theme_minimal()
sauver("fig_4_1_adr_hotel.png")

# --- Comparaison 2 : délai de réservation selon l'annulation -----------------
h |>
  group_by(is_canceled) |>
  summarise(n = n(), moy = mean(lead_time), med = median(lead_time),
            et = sd(lead_time), min = min(lead_time), max = max(lead_time))

# Figure 4.2
ggplot(h, aes(factor(is_canceled, labels = c("Non annulée", "Annulée")), lead_time)) +
  geom_boxplot(fill = "steelblue") +
  labs(title = "Délai de réservation selon le statut d'annulation",
       x = "Statut de la réservation", y = "Délai de réservation (jours)") +
  theme_minimal()
sauver("fig_4_2_lead_time_annulation.png")

# --- Comparaison 3 : ADR selon le mois d'arrivée -----------------------------
h |>
  group_by(arrival_date_month) |>
  summarise(
    n   = sum(!is.na(adr)),
    moy = mean(adr, na.rm = TRUE),
    med = median(adr, na.rm = TRUE),
    et  = sd(adr, na.rm = TRUE)
  )

# Figure 4.3
h |>
  group_by(arrival_date_month) |>
  summarise(moy = mean(adr, na.rm = TRUE)) |>
  ggplot(aes(arrival_date_month, moy, group = 1)) +
  geom_line(color = "steelblue") + geom_point(color = "steelblue") +
  labs(title = "Variation du tarif journalier moyen selon le mois",
       x = "Mois d'arrivée", y = "ADR moyen") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
sauver("fig_4_3_adr_mois_courbe.png")

# Figure 4.4
ggplot(h, aes(arrival_date_month, adr)) +
  geom_boxplot(fill = "steelblue") +
  coord_cartesian(ylim = c(0, 300)) +
  labs(title = "Distribution des tarifs selon le mois d'arrivée",
       x = "Mois d'arrivée", y = "ADR") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
sauver("fig_4_4_adr_mois_boxplot.png")

# --- Question 2 : proportion d'annulations selon l'hôtel ---------------------
tab <- table(h$hotel, h$is_canceled)
tab
round(100 * prop.table(tab, 1), 2)

# Figure 4.5
ggplot(h, aes(hotel, fill = factor(is_canceled, labels = c("Non annulée", "Annulée")))) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Répartition des annulations selon le type d'hôtel",
       x = "Type d'hôtel", y = "Proportion des réservations", fill = "Statut") +
  theme_minimal()
sauver("fig_4_5_annulation_hotel.png")

# --- Question 3 : relation entre lead_time et adr ----------------------------
cor(h$lead_time, h$adr, use = "complete.obs")   # -0,063

# Figure 4.6
ggplot(h, aes(lead_time, adr)) +
  geom_bin2d() +
  coord_cartesian(xlim = c(0, 400), ylim = c(0, 300)) +
  labs(title = "Relation entre le délai de réservation et le tarif",
       subtitle = "Visualisation ciblée : lead_time <= 400 et ADR <= 300",
       x = "Délai de réservation (jours)", y = "Tarif journalier moyen (ADR)",
       fill = "Effectif") +
  theme_minimal()
sauver("fig_4_6_bin2d.png")

# Figure 4.7 - Carte de densité 2D
h |>
  filter(!is.na(adr), !is.na(lead_time)) |>
  ggplot(aes(x = lead_time, y = adr)) +
  geom_density_2d_filled(alpha = 0.8) +
  geom_density_2d(color = "white", linewidth = 0.2) +
  coord_cartesian(xlim = c(0, 400), ylim = c(0, 300)) +
  labs(title = "Carte de densité : délai de réservation et tarif",
       x = "Délai de réservation (jours)", y = "ADR",
       fill = "Niveau de densité") +
  theme_minimal()
sauver("fig_4_7_densite_2d.png")

# =============================================================================
# ÉTAPE 5 - Synthèse (voir le rapport)
# =============================================================================
