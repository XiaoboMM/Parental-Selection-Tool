BC2F2enrichmentDH <- function(P1, selected_pop, qtl_file, pop_file){
  df <- pop_file%>%
    select(-Trait)%>%
    select(QTL, P1, everything())%>%
    gather(mat, allele, c(3:(dim(pop_file)[2]-1)))
  names(df)[c(1,2, 3)] = c("QTL", "P1","Name")
  dat <- selected_pop%>%
    filter(Name != P1)%>%
    select(Name)
  
  data <- merge(dat, df, by = "Name", all.x = T)%>%
    filter(P1 != 0)%>%
    filter(allele != 0)
  
  ####find different loci
  for (line in c(1:dim(data)[1])){
    if (data[line, 3] != data[line, 4]){
      data[line, 5] = 1
    } else {
      data[line, 5] = 0
    }
  }
  data1 <- filter(data, V5 == 1)%>%
    select(-V5)
  
  ###添加QTL的位置信息
  qtl <- qtl_file%>%
    select(QTL, Chromosome, Genetic_position)
  
  mydata <- merge(data1, qtl, by = "QTL", all.x = T)%>%
    arrange(Chromosome, Genetic_position)
  
  ######计算NminPBC2F2enrichmentDH，计算PBC2F2enrichmentDH最小群体大小
  data_pop_size <- data.frame(stringsAsFactors = F)
  for (trait in (1: dim(dat)[1])){
    ##############计算PBC2F2enrichmentDH最小群体大小
    p_inf <- filter(mydata, Name == dat[trait, 1]) 
    ###按照不同染色体进行分组
    mm <- c()
    nn = 1
    f = 1
    chr <- unique(p_inf$Chromosome)
    
    ################################################################
    for (chrom in 1:length(chr)){
      #print(chrom)
      p_inf_chr <- filter(p_inf, Chromosome == chr[chrom])####提取每条染色体上的位点信息
      if (dim(p_inf_chr)[1] > 1){##染色体上存在两个或两个以上的位点
        for (i in 1:(dim(p_inf_chr)[1]-1)){
          Dis <- as.numeric(p_inf_chr[i+1, 6]-p_inf_chr[i, 6])##两标记间遗传距离
          r = 1/2*(1-exp(-Dis/50))###重组率
          R=2*r/(1+2*r)
          if (p_inf_chr[i, 3] == 1){ ##########################P1BC2F2enrichmentDH#################
            if (p_inf_chr[i, 3] != p_inf_chr[i+1, 3]){
              ##P1=AAbb, P2 = aaBB, P1BC2F2enrichmentDH代不同基因型频率如下
              ##f8 = f(P1BC2F2 enrichment), P1: AAbb and P2: aaBB
              #p(AABB) = [1/16-1/16*(1-r)^2*(1-r^2)+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1-r)*(1/8*r^2*(1-r)^2)+1/2*r*(1/8*(1-r)^4)]/p8
              p8 = 1/16-1/16*(1-r)^2*(1-r^2)+1/8-1/8*(1-r)^2*(1-r+r^2)+1/8-1/8*(1-r)^2*(1-r+r^2)+1/8*r^2*(1-r)^2+1/8*(1-r)^4##携带两个目的基因均为纯合或杂合概率
              p = (1/16-1/16*(1-r)^2*(1-r^2)+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1-r)*(1/8*r^2*(1-r)^2)+1/2*r*(1/8*(1-r)^4))/p8##携带两个目的基因均为纯合概率
            } else {
              ##P1=AABB, P2 = aabb, P1BC2F2enrichmentDH代不同基因型频率如下
              ##f7 = f(P1BC2F2 enrichment), P1: AABB and P2: aabb
              ##p(AABB) = (5/8+1/8*(1-r)^2+1/16*(1-r)^4+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1-r)*(1/8*(1-r)^4)+1/2r*(1/8*r^2*(1-r)^2))/p7
              p7 = 5/8+1/8*(1-r)^2+1/16*(1-r)^4+1/8-1/8*(1-r)^2*(1-r+r^2)+1/8-1/8*(1-r)^2*(1-r+r^2)+1/8*(1-r)^4+1/8*r^2*(1-r)^2##携带两个目的基因均为纯合或杂合的概率
              p = (5/8+1/8*(1-r)^2+1/16*(1-r)^4+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1/8-1/8*(1-r)^2*(1-r+r^2))+1/2*(1-r)*(1/8*(1-r)^4)+1/2*r*(1/8*r^2*(1-r)^2))/p7##携带两个目的基因均为纯合的概率
            }
          } else {  ###################P2BC2F2enrichmentDH##################
            if (p_inf_chr[i, 3] != p_inf_chr[i+1, 3]){
              ##P1=AAbb, P2 = aaBB, P2BC2F2enrichmentDH代不同基因型频率如下
              ##f10 = f(P2BC2F2 enrichment), P1: AAbb and P2: aaBB
              ##p(AABB) = (1/16-1/16*(1-r)^2*(1-r^2)+1/2*(1/8*r*(1-r)^3)+ 1/2*(1/8*r*(1-r)^3)+1/2*(1-r)*(1/8*r^2*(1-r)^2)+1/2*r*(1/8*(1-r)^4))/p10
              p10 = 1/16-1/16*(1-r)^2*(1-r^2)+1/8*r*(1-r)^3+1/8*r*(1-r)^3+1/8*r^2*(1-r)^2+1/8*(1-r)^4##携带两个目的基因均为纯合或杂合概率
              p = (1/16-1/16*(1-r)^2*(1-r^2)+1/2*(1/8*r*(1-r)^3)+ 1/2*(1/8*r*(1-r)^3)+1/2*(1-r)*(1/8*r^2*(1-r)^2)+1/2*r*(1/8*(1-r)^4))/p10##携带两个目的基因均为纯合概率
            } else {
              ##P1=AABB, P2 = aabb, P2BC2F2enrichmentDH代不同基因型频率如下
              ##f9 = f(P2BC2F2 enrichment), P1: AABB and P2: aabb
              ##p(AABB) = (1/16*(1-r)^4+1/2*(1/8*r*(1-r)^3)+1/2*(1/8*r*(1-r)^3)+1/2*(1-r)*(1/8*(1-r)^4)+1/2*r*(1/8*r^2*(1-r)^2))/p9
              p9 = 1/16*(1-r)^4+1/8*r*(1-r)^3+1/8*r*(1-r)^3+1/8*(1-r)^4+1/8*r^2*(1-r)^2##携带两个目的基因均为纯合或杂合的概率
              p = (1/16*(1-r)^4+1/2*(1/8*r*(1-r)^3)+1/2*(1/8*r*(1-r)^3)+1/2*(1-r)*(1/8*(1-r)^4)+1/2*r*(1/8*r^2*(1-r)^2))/p9##携带两个目的基因均为纯合的概率
            }
          }
          mm[nn] = p
          nn = nn + 1
          f = f*p
        }
      } else {##染色体上存在1个位点
        if (p_inf_chr[1, 3] == 1){ ##########################P1BC2F2enrichmentDH#################
          p = 14/15
        } else { ##################P2BC2F2enrichmentDH#################
          p = 2/3
        }
        mm[nn] = p
        nn = nn + 1
        f = f*p
      }
    }
    #print(mm)
    ###α = 0.01
    if (f == 0){
      NminF2 = "∞"
    } else {
      NminF2 <- ceiling(log(0.01)/log(1-f))
    }
    
    mat_name = dat[trait, 1]
    data_pop_size[trait, 1] = mat_name
    data_pop_size[trait, 2] = NminF2
  }
  names(data_pop_size) = c("Name", "NminBC2F2enrichmentDH")
  write.csv(data_pop_size, paste("NminBC2F2enrichmentDH", "_population_size.csv", sep = ""), quote = F, row.names = F)
  
}