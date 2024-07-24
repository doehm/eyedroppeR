# tsp

pal <- c('#211B1F', '#515979', '#98B878', '#CBD293', '#EEEEB6', '#C4A65F', '#7B8747', '#605216')
show_pal(pal[-7])
pal <- c('#283746', '#A74822', '#E7DBB8', '#BCB297', '#868D8C', '#576570', '#155EB2', '#11437D')
pal <- sample(pal, 8)

sort_on <- c("r", "g", "b", "h", "s", "v")
sort_on <- c("r", "v")

# convert to rgb
rgb <- col2rgb(pal)/255
rownames(rgb) <- c("r", "g", "b")
hsv <- rgb2hsv(rgb, maxColorValue = 1)

mat <- cbind(t(rgb), t(hsv))
mat <- mat[,sort_on]

dmat <- as.matrix(dist(mat))

total_dist <- rep(NA, length(pal))
for(start in 1:length(pal)) {
  dmat_k <- dmat[start,]
  id <- sort(dmat_k, index.return = TRUE)
  total_dist[start] <- sum(diff(dmat[start, id$ix]))
}

dmat_k <- dmat[which.min(start),]
id <- sort(dmat_k, index.return = TRUE)
pal_ordered <- pal[id$ix]
show_pal(pal_ordered)


pal_ordered <- t(hsv) |>
  as_tibble() |>
  mutate(pal = pal) |>
  arrange(h, s, v)

show_pal(pal_ordered$pal)
