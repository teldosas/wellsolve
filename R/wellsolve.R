#' Minimize the Total Pumping Cost
#' @description  Minimize the Total Pumping Cost from an Aquifer
#' to a Water Tank, Via a Pipe Network
#'
#' @param projected A character string of projection arguments;
#' the arguments must be entered exactly as in the PROJ.4 documentation;
#' if the projection is unknown, use as.character(NA),
#' it may be missing or an empty string of zero length and
#' will then set to the missing value.
#' With rgdal built with PROJ >= 6 and GDAL >= 3,
#' the +init=key may only be used with value epsg:<code>.
#' @param T Aquifer’s transmissivity in square meters per second.
#' @param R Radius of influence of the system of wells in meters.
#' @param ff Friction coefficient along the pipes
#' @param qtot Total required flow rate in qubic meters per second.
#' @param r0 Diameter of all wells in meters.
#' @param Dlist A vector with the diameters of the pipes in meters.
#' @param qextra A vector with the required flow rates for the extra wells
#' in qubic meters per second.
#' @param nw Number of wells + 1 (the tank).
#' @param xc A vector with x coordinates. The first value is the tank and
#' the rest are the wells.
#' @param yc A vector with y coordinates. The first value is the tank and
#' the rest are the wells.
#' @param links ??? The links between the wells.
#' @param nwextra Number of extra wells.
#' @param xextra A vector with x coordinates for the extra wells.
#' @param yextra A vector with y coordinates for the extra wells.
#' @param xstart A wild guess about the result.
#' This helps the algorithm search for the result in the correct area
#'
#' @return ??? A list of 7
#' @export
#'
#' @example man/examples/example.R
wellsolve <- function(projected, T,R,ff,qtot,r0,Dlist,qextra,nw,
                      xc,yc,links,nwextra,xextra,yextra, xstart) {
  temp <- calculate_distances(xc, yc, projected, r0, nw)
  r <- temp$r; coords <- temp$coords; test <- temp$test;
  temp <-
    calculate_distances(c(xextra,xc), c(yextra,yc), projected, r0, nwextra)
  rextra <- temp$r; coordsextra <- temp$coords; testextra <- temp$test;

  lines <-list()
  names<-c()
  i=0
  while (i<nw-1) {
    i=i+1
    names<-c(names,paste0("line",i))
    var <- rbind(c(coords[i+1,1],coords[i+1,2]),c(coords[links[i,2]+1,1],coords[links[i,2]+1,2]))
    lines[[names[i]]] <-  raster::spLines(var, attr=data.frame(start=i,end=links[i,2]), crs=projected)
  }

  printmap <- render_diagram(test, lines, qextra, nw, testextra)

  Cmatrix <- data.frame(matrix(ncol=(nw-1), nrow=(nw-1)))
  Cmatrix[,] <-0

  i=0
  while (i<(nw-1)){
    i=i+1
    Cmatrix[[i,i]]<-1
    if (!(lines[[i]]@data[["end"]]==0)) {
      j <- lines[[i]]@data[["end"]]
      while (!(j==0)) {
        Cmatrix[[j,i]] <- 1
        j <- lines[[j]]@data[["end"]]
      }
    }
  }


  cn_ <- Cmatrix[,]-Cmatrix[,(nw-1)]
  ct <- data.frame(matrix(ncol=(nw-1), nrow=(nw-1)))
  i=0
  while (i<(nw-1)){
    i=i+1
    j=0
    while(j<(nw-1)){
      j=j+1
      ct[[i,j]] <- cn_[[j,i]]
    }
  }

  kx <- data.frame(matrix(ncol=(nw-1), nrow=(nw-1)))
  kx[,] <-0
  i=0
  while (i<(nw-1)) {
    i=i+1
    lines[[i]]@data[[3]] <- r[lines[[i]]@data[[1]]+1,lines[[i]]@data[[2]]+1]
    # Darcy–Weisbach formula
    lines[[i]]@data[[4]] <-
      8*ff*lines[[i]]@data[[3]] / ( (Dlist[[i]]^5) * 9.81 *(pi)^2 )
    kx[[i,i]]<-lines[[i]]@data[[4]]
  }

  rnot<-r[2:nw,2:nw]
  a <- data.frame(matrix(ncol=(nw-1), nrow=(nw-1)))
  i=0
  while (i<(nw-1)) {
    i=i+1;  j=0
    while (j<(nw-1)) {
      j=j+1
      a[[i,j]] <- -log(rnot[[i,j]]/rnot[[j,(nw-1)]]) * (1/(2*pi*T))
    }
  }
  a[(nw-1),] <- 0.5

  rextranot<-rextra
  rextranot[(nwextra-nw+1):nrow(rextranot),(nwextra-nw+1):nrow(rextranot)]<-0

  sextra <- calculate_s(ncol=nwextra-nw, nrow=nwextra, qextra, rextranot, R, T)
  dextra <- sextra[((nwextra-nw+1):nrow(sextra)),1]
  dextra <- dextra[1]-dextra
  dextra <- dextra[2:nw]


  dmatrix <- data.frame(matrix(ncol=1, nrow=(nw-1)))
  dmatrix[,] <-0
  dmatrix[1:5,1] <-dextra[1:5]-dextra[6]
  dmatrix[(nw-1),1]<-qtot

  QQ<-data.frame(matrix(ncol=1, nrow=length(lines)))

  main <- function(qn) {
    resultnew<-rep(NA,length(qn))
    q<-data.frame(matrix(ncol=1, nrow=(nw-1)))
    q[1:(nw-1),1] <- qn[1:(nw-1)]
    QQ<- as.matrix(Cmatrix) %*% as.matrix(q)
    QQsquare<- QQ^2
    result<-2 * as.matrix(a) %*% as.matrix(q) + 3 * as.matrix(ct) %*% as.matrix(kx) %*% QQsquare -as.matrix(dmatrix)
    resultnew[1:(nw-1)]<-result[1:(nw-1),1]
    return<- resultnew
  }

  newans<- nleqslv::nleqslv(xstart, main, control=list(trace=1,btol=.01,delta="newton"))
  qresult<-newans[["x"]]

  QQ <- as.matrix(Cmatrix) %*% as.matrix(qresult)
  QQsquare<- QQ^2
  hf <- as.matrix(kx) %*% QQsquare

  s <- calculate_s(ncol=nw-1, nrow=nw-1, qresult, rnot, R, T)

  sfinal <- s[1:nrow(s),1] + sextra[(nwextra-nw+2):nwextra,1]

  return<-list(qresult,hf,s,printmap,sfinal,as.matrix(kx),QQsquare)
}

calculate_distances <- function(xc, yc, projected, r0, nw) {
  xy<-data.frame(matrix(ncol=2, nrow=nw)) ; xy[[1]] <- xc ; xy[[2]] <- yc
  coords <- cbind(Easting=xy[1], Northing=xy[2])
  test = sp::SpatialPointsDataFrame(coords, xy, proj4string = sp::CRS(projected))
  test@data[[3]] <- 0:(nw-1)

  r<-rgeos::gDistance(test, byid=TRUE)

  i=0; while (i<nw) {i=i+1; r[[i,i]]=r0}

  list(r=r, coords=coords, test=test)
}

calculate_s <- function(ncol, nrow, q, rnot, R, T) {
  sbasic <- data.frame(matrix(ncol=ncol,nrow=nrow))
  s <- data.frame(matrix(ncol=1,nrow=nrow))
  j=0
  while (j<nrow){
    j=j+1 ;   k=0
    while (k<ncol){
      k=k+1
      sbasic[[j,k]]<- (-1/(2*T*pi)) * q[k] * log(rnot[k,j]/R)
    }
    s[[j,1]] <- sum(sbasic[j,])
  }

  s
}

render_diagram <- function(test, lines, qextra, nw, testextra) {
  final_map<- test
  final_map@data[[4]] <- 10
  final_map@data[[1,4]] <- 0
  colnames(final_map@data)<-c("x","y","number","points")
  Mypal <- c('#FF0000','#313695')


  fplot <- function(nw) {
    printm<- tmap::tm_shape(final_map) + tmap::tm_symbols(size= 1, col="number", breaks=c(-5 , 0.5, 100),
                                                          style = "fixed",  palette=Mypal, contrast=1, labels = c("tank","wells"))
    i=0
    while(i<(nw-1)){
      i=i+1
      printm<-printm+tmap::qtm(lines[[i]])
    }
    return<-printm
  }


  if(!(sum(qextra)==0)) {
    printmap<-fplot(nw)+tmap::qtm(testextra)
  } else {
    printmap<-fplot(nw)
  }
}
