---
layout: post
title: 使用R爬取HMDB和KEGG数据库
description: 因为最近需要使用代谢通路数据，因此想到了使用R编写爬虫爬取KEGG和HMDB数据。
---

## **R语言爬虫**
******************************************
虽然相对于python来说，R语言爬虫并不是那么流行，但是对于比较小的数据爬取量，使用R还是很方便的。R的数据爬取比较流行的是利用XML和RCurl包进行爬取，在这篇博客里面，我就利用XML和RCurl包进行KEGG和HMDB的数据爬取。

## **爬取KEGG通路信息**
******************************************
因为我需要的信息是KEGG的通路信息，比较简单，也就是每个通路包含哪些代谢物，只要人的metaboloic pathway，因此，我需要先将KEGG中的通路的网页链接拿到。

```
library(XML)
library(RCurl)
##从kegg主页上抓取代谢通路的url
URL = getURL("http://www.genome.jp/kegg/pathway.html#global")
doc <- htmlParse(URL,encoding="utf-8")
xpath.a <- "//a/@href"
node <- getNodeSet(doc, xpath.a)
url1 <- sapply(node, as.character)

xpath.b <- "//a[@href]"
name <- getNodeSet(doc, xpath.b)
name <- sapply(name, xmlValue)

name2 <- name[59:247]
url2 <- url1[59:247]

url3 <- url2[grep("show", url2)]

pathwat.name <- NULL
metabolite.id <- list()
metabolite.name <- list()
for (i in 1:length(url3)) {
  cat(paste(i,"/",length(url3)))
  cat("\n")
  URL <- paste("http://www.genome.jp", url3[i], sep = "")
  URL = getURL(URL)
  doc<-htmlParse(URL,encoding="utf-8")
  xpath <- "//option[@value='hsa']"
  node<-getNodeSet(doc, xpath)
  if (length(node) ==0 ) {
    cat("No human pathwat.")
    next()
  }else{
    URL <- paste("http://www.genome.jp", url3[i], sep = "")
    URL <- gsub(pattern = "map=map", replacement = "map=hsa", x = URL)
    doc<-htmlParse(URL,encoding="utf-8")
    xpath1 <- "//title"
    node<-getNodeSet(doc, xpath1)
    pathway.name[i] <- xmlValue(node[[1]])
    pathway.name[i] <- substr(pathway.name[i], start = 2, stop = nchar(pathway.name[i])-1)

    xpath2 <- "//area[@shape='circle']/@title"
    node<-getNodeSet(doc, xpath2)
    metabolite <- lapply(node, function(x) as.character(x))
    metabolite.name[[i]] <- substr(metabolite, start = 9, nchar(metabolite)-1)
    metabolite.id[[i]] <- substr(metabolite, start = 1, stop = 6)
  }
}
```

下面对爬取到的代谢通路进行筛选。

```
idx <- which(!is.na(pathway.name))
pathway.name1 <- pathway.name[idx]
metabolite.id1 <- metabolite.id[idx]
metabolite.name1 <- metabolite.name[idx]

pathway.name2 <- pathway.name1[-c(83,84)]
metabolite.id2 <- metabolite.id1[-c(83,84)]
metabolite.name2 <- metabolite.name1[-c(83,84)]
```

将爬取到的信息保存输出。

```
met.name <- NULL
met.id <- NULL
path.name <- NULL
for(i in 1:length(pathway.name2)) {
  met.name[i] <- paste(metabolite.name2[[i]], collapse = ";")
  met.id[i] <- paste(metabolite.id2[[i]], collapse = ";")
  path.name[i] <- gsub(pattern = "KEGG PATHWAY: ", "", pathway.name2[i])
  path.name[i] <- substr(path.name[i], start = 1, stop = nchar(path.name[i])-23)
}


kegg <- data.frame(path.name, met.name, met.id)
write.csv(kegg, "kegg.csv", row.names = F)

save(path.name, file = "path.name")
save(met.name, file = "met.name")
save(met.id, file = "met.id")

kegg.met <- list()
kegg.met[[2]] <- sapply(path.name, list)
kegg.met[[1]] <- metabolite.name2
kegg.met[[3]] <- metabolite.id2

names(kegg.met) <- c("gs", "pathwaynames", "metid")

save(kegg.met, file = "kegg.met")
```

## **爬取HMDB通路信息**
******************************************
首先爬取HMDB的通路信息。

```
##抓取HMDB通路信息
library(XML)
library(RCurl)

hmdb.main <- "http://www.hmdb.ca/pathways?page="
hmdb.main <- paste(hmdb.main, c(2:46), sep = "")
hmdb.main <- c("http://www.hmdb.ca/pathways", hmdb.main)

##从HMDB主页上抓取代谢通路的url
path.name <- list()
metabolite.id <- list()
spec <- list()
path.class <- list()
for (i in 40:length(hmdb.main)) {
  cat(paste("page",i))
  cat(":")
  URL = getURL(hmdb.main[i])
  doc<-htmlParse(URL,encoding="utf-8")
  xpath1 <- "//div[@class='panel-heading']"
  node1 <- getNodeSet(doc, xpath1)
  pathway.name <- sapply(node1, xmlValue)

  cat(paste(length(pathway.name), "pathways"))
  cat("\n")

  path.name[[i]] <- pathway.name

  xpath2 <- "//div[@class='panel-body']"
  node2 <- getNodeSet(doc, xpath2)

  metabolite <- sapply(node2, xmlValue)
  metabolite <- unname(sapply(metabolite, function(x) {gsub("Show", " ", x)}))

  idx <- sapply(metabolite, function(x) {gregexpr("HMDB[0-9]{5}", x)})

  met.id <- list()
  for (j in 1:length(idx)) {
    id <- NULL
    for (k in 1:length(idx[[j]])) {
      id[k] <- substr(metabolite[j], idx[[j]][k], idx[[j]][k]+8)
    }
    met.id[[j]] <- id
  }

  metabolite.id[[i]] <- met.id

  xpath.a <- "//a[@class='link-out']/@href"
  node<-getNodeSet(doc, xpath.a)

  url1 <- sapply(node, as.character)
  url1 <- substr(url1, start = 1, stop = 29)
  url1 <- url1[!duplicated(url1)]


  ###获取通路的人种和类别
  species <- NULL
  metabolic <- NULL
  for (t in 1:length(url1)) {
    cat(paste("t:",t));cat(" ")
    URL = getURL(url1[t])
    doc <- htmlParse(URL,encoding="utf-8")
    xpath <- "//div[@class='species']/text()"
    node <- getNodeSet(doc, xpath)
    species[t] <- xmlValue(node[[1]])

    xpath <- "//div[@id='des_subject']/text()"
    node <- getNodeSet(doc, xpath)
    metabolic[t] <- xmlValue(node[[1]])

  }

  spec[[i]] <- species
  path.class[[i]] <- metabolic

}
```

对爬取到的代谢通路进行筛选。

```
save(path.name, file = "path.name")
save(metabolite.id, file = "metabolite.id")
save(spec, file = "spec")
save(path.class, file = "path.class")


pathway.name <- NULL
metabolite.ID <- list()
species <- NULL
pathway.class <- NULL
for (i in 1:length(path.name)) {
  pathway.name <- c(pathway.name, path.name[[i]])
  metabolite.ID <- c(metabolite.ID, metabolite.id[[i]])
  species <- c(species, spec[[i]])
  pathway.class <- c(pathway.class, path.class[[i]])
}


pathway.class <- substr(x = pathway.class, 1, regexpr("\\\n", pathway.class)-1)

metabolite.name <- list()
for (i in 1:length(metabolite.ID)) {
  id <- metabolite.ID[[i]]
  idx <- match(id, hmdbdatabase[,1])
  name <- hmdbdatabase[idx,2]
  metabolite.name[[i]] <- name
}

a <- unlist(lapply(metabolite.name, function(x) {paste(x, collapse = ";")}))
b <- unlist(lapply(metabolite.ID, function(x) {paste(x, collapse = ";")}))

idx <- grep("Metabolic", pathway.class)

metabolite.name <- metabolite.name[idx]
metabolite.ID <- metabolite.ID[idx]
pathway.name <- pathway.name[idx]
pathway.class <- pathway.class[idx]
species <- species[idx]

hmdb.pathway <- data.frame(pathway.name, pathway.class,a, b)[idx,]
write.csv(hmdb.pathway, "hmdb.pathway.csv")

a <- list()
for (i in 1:length(pathway.name)) {
  a[[i]] <- pathway.name[i]
}

pathway.name <- a

hmdb.met <- list(gs = metabolite.name, pathwaynames = pathway.name, id = metabolite.ID)
save(hmdb.met, file = "hmdb.met")
```

## **爬取HMDB代谢物信息**
******************************************
首先，获得所有代谢物的页面链接。

```
###抓取HMDB代谢物信息
library(XML)
library(RCurl)

hmdb.main <- "http://www.hmdb.ca/metabolites?c=hmdb_id&d=up&page="
hmdb.main <- paste(hmdb.main, c(2:1681), sep = "")
hmdb.main <- c("http://www.hmdb.ca/metabolites", hmdb.main)

##从HMDB主页上抓取代谢物的url
url <- NULL
for (i in 1:length(hmdb.main)) {
  cat(i)
  cat(" ")
  URL = getURL(hmdb.main[i])
  doc<-htmlParse(URL,encoding="utf-8")
  xpath <- "//a[@href]/@href"
  node<-getNodeSet(doc, xpath)
  url1 <- sapply(node, as.character)
  url1 <- url1[grep("metabolites/HMDB", url1)]
  url1 <- unique(url1)
  url <- c(url, url1)
}

url1 <- paste("http://www.hmdb.ca/",url, sep = "")
save(url1, file = "url1")
```

下面开始进行代谢物信息爬取。

```
library(mailR)
for (i in 1:400) {
  cat(paste((i-1)*100+1,"-",i*100,"/", length(url1), sep = ""))
  cat("\n")
  URL <- getURL(url1[((i-1)*100+1):(i*100)])
  doc <- htmlParse(URL, encoding="utf-8")
  xpath1 <- "//tr"
  node1 <- getNodeSet(doc, xpath1)
  node1 <- sapply(node1, xmlValue)

  HMDB_ID[((i-1)*100+1):(i*100)] <-
    gsub(pattern = "HMDB ID", replacement = "",node1[grep("HMDB ID", node1)])

  Common_Name[((i-1)*100+1):(i*100)] <-
    gsub("Common Name", "",node1[grep("Common Name", node1)])

  temp <- gsub("SynonymsValueSource", "",node1[grep("Synonyms", node1)])
  temp <- gsub("Generator", ";",temp)
  temp <- gsub("ChEMBL", ";",temp)
  temp <- gsub("ChEBI", ";",temp)
  Synonyms[((i-1)*100+1):(i*100)] <-
    gsub("HMDB", ";",temp)

  Chemical_Formula[((i-1)*100+1):(i*100)] <-
    gsub("Chemical Formula", "",node1[grep("Chemical Formula", node1)])

  Monoisotopic_Molecular_Weight[((i-1)*100+1):(i*100)] <-
    gsub("Monoisotopic Molecular Weight", "",node1[grep("Monoisotopic Molecular Weight", node1)])

  IUPAC_Name[((i-1)*100+1):(i*100)] <-
    gsub("IUPAC Name", "",node1[grep("IUPAC Name", node1)])

  Traditional_Name[((i-1)*100+1):(i*100)] <-
    gsub("Traditional Name", "",node1[grep("Traditional Name", node1)])

  CAS_Registry_Number[((i-1)*100+1):(i*100)] <-
    gsub("CAS Registry Number", "",node1[grep("CAS Registry Number", node1)])

  Origin[((i-1)*100+1):(i*100)] <-
    gsub("Origin", "",node1[grep("Origin", node1)])

  path <- gsub("PathwaysNameSMPDB LinkKEGG Link", "",node1[grep("Pathways", node1)])
  Pathways[((i-1)*100+1):(i*100)] <-
    substr(path, 1, stop = regexpr("SMP", path)-1)

  ##每100次保存一次
  if (i*100 %in% seq(100, 60000, by = 100)) {
    cat("save data...\n")
    save(HMDB_ID,
         Common_Name,
         Synonyms,
         Chemical_Formula,
         Monoisotopic_Molecular_Weight,
         IUPAC_Name,
         Traditional_Name,
         CAS_Registry_Number,
         Origin,
         Pathways,
         file = paste("hmdb.data",i*100))

    send.mail(from = "yourmail1@163.com",
              to = c("youmail20@163.com"),
              subject = paste("WZZ GO ON:", i),
              body = paste("WZZ still go on", i),
              smtp = list(host.name = "smtp.163.com", port = 465, user.name = "yourmail1", passwd = "passward", ssl = TRUE),
              authenticate = TRUE,
              send = TRUE)
  }

}

```
因为代谢物信息比较大，可能需要一晚上，因此想到了没爬取100个，就给自己发一封邮件，来对程序进行监控。

写的比较粗糙，有时间再好好修改一下。
