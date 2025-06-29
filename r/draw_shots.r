source("./r/utils/plot/get_distance.r")
source("./r/utils/plot/plot_empty_field.r")
source("./r/utils/get_related_event_id.r")
source("./r/utils/xg/get_xg_proportion.r")
source("./r/utils/get_match_json.r")
source("./r/utils/check_libraries.r")

check_libraries()

home_team   <- "Real Madrid"
away_team   <- "Barcelona"
match_id    <- "68319"
competition <- "la_liga"

match_json <- get_match_json(home_team, away_team, match_id, competition)

img_path <- paste0("./plots/shots/", home_team, "_vs_", away_team, "_", match_id, ".png")


width  <- match_json[[5]]$location[1]*2
height <- match_json[[5]]$location[2]*2

png(file=img_path, width=width*10, height=height*10)

plot_field(width, height) 

play_type <- c(16, 25) # 16 = shot 30 = pass

for (i in 1:length(match_json)){
    current_play_type <- (match_json[[i]]$type$id)

    if(current_play_type %in% play_type ){ 
        
        if (current_play_type == 16){
            source      <- match_json[[i]]$location
            source_y    <- height-source[2]

            destination   <- match_json[[i]]$shot$end_location
            destination_y <- height-destination[2]

            color_source <- "black"
            color_segment <- "red"
            point_size <- 1.5

            if (match_json[[i]]$team$name == away_team){
                source[1] = 120 - source[1]
                destination[1] = 120 - destination[1]            
            } 

            if ((match_json[[i]]$shot$outcome$id == 97) || (match_json[[i]]$shot$type$id == 88)){
                color_source <- "green"
                point_size <- get_xg_proportion(match_json[[i]])
            }

            
        }else if (current_play_type == 25){
            color_source <- "blue"
            color_segment <- "blue"
            point_size <- 3
            if (match_json[[i]]$possession_team$name == home_team){
                source <- match_json[[i]]$location
                destination <- c(120, 40)
            } 
        }
        distance<-get_distance(source, destination)

        points(source[1], source_y, col=color_source, pch=19, cex=point_size)
        segments(source[1], source_y, destination[1], destination_y, col=color_segment, lwd=1)
    }
}

mtext(paste0(home_team, " vs ", away_team), side = 1, line = 2, cex = 2)
dev.off()