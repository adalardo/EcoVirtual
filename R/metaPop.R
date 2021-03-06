###########################################
### Ecovirtual - Metapopulations Models ###
###########################################
##' Metapopulation Models
##' 
##' Simulate metapopulation dynamics with propagules seed rain, internal
##' colonization and rescue effect.
##' 
##' 'metaPop' is the seed rain metapopulation model, including only propagules
##' seed rain from a external pool (no extinction).
##' 
##' 'metaCi' is the Internal Colonization model, where number of propagules
##' depends on number of occupied patches, there is no external pool.
##' 
##' 'metaEr' is the Rescue Effect model, where extinction probability is
##' negatively associated with number of occupied patches.
##' 
##' 'metaCiEr' includes both effects: Rescue Effect and Internal Colonization.
##' 
##' The number of patches in the simulated landscape is defined by rw*cl.
##'
##' @aliases metapopulation metaPop metaCi metaEr metaCiEr
##' @param cl number of columns for the simulated landscape.
##' @param rw number of rows for the simulated landscape.
##' @param f0 initial proportion of occupied patches.
##' @param pi probability of colonization.
##' @param pe probability of extinction.
##' @param ci colonization coefficient, represents the maximum probability of
##' colonization (when f=1) and should be a number between 0 and 1.
##' @param ce coefficient of extinction, represents the maximum probability of
##' extinction (when f=0) and should be a number between 0 and 1.
##' @param tmax maximum simulation time.
##' @param anima show animation frames.
##' @return Metapopulation functions return graphics with the simulation
##' results. These functions also return an invisible array with the simulation
##' data.
##' @author Alexandre Adalardo de Oliveira and Paulo Inacio Prado
##' \email{ecovirtualpackage@@gmail.com}
##' @seealso \url{http://ecovirtual.ib.usp.br}
##' @references Gotelli, N.J. 1991. Metapopulation models: the rescue effect,
##' the propagule rain, and the core-satellite hypothesis. The American
##' Naturalist 138:768-776.
##' 
##' Gotelli, N.J. 2008. A primer of Ecology. 4th ed. Sinauer Associates, 291pp.
##' @keywords metapopulation simulation
##' @examples
##' 
##' \dontrun{
##' metaPop(cl=10,rw=10,f0=0.5,pi=0.3,pe=0.15, tmax=100)
##' metaCi(cl=10,rw=10,f0=0.1,ci=1,pe=0.5, tmax=100)
##' metaEr(cl=10, rw=10, f0=0.2, pi=0.2, ce=0.15, tmax=100)
##' metaCiEr(cl=10, rw=10, f0=0.2, ci=0.2, ce=0.15, tmax=100)
##' }
##' 
########################
### Propagulus Seed Rain
########################
metaPop <-function(cl,rw,f0,pi,pe, tmax, anima=TRUE)
{
    if(pi>1 | pe>1 |pi<0 | pe<0)
    {
        stop("probabilities (pe and pi) shoulb be a number between 0 and 1")
    }
paisag=array(0,dim=c(rw,cl,tmax))
nmanchas=cl*rw
paisag[,,1]=matrix(sample(c(1,0),nmanchas,prob=c(f0,1-f0), replace=TRUE),rw,cl)
resultado=numeric()
for(tc in 2:tmax)
    {
        paisag[,,tc][paisag[,,(tc-1)]==1]<-sample(c(0,1),sum(paisag[,,(tc-1)]), replace=TRUE, prob=c(pe,1-pe))
        paisag[,,tc][paisag[,,(tc-1)]==0]<-sample(c(0,1),cl*rw-sum(paisag[,,(tc-1)]), replace=TRUE, prob=c(1-pi,pi))
        resultado[tc-1]=sum(paisag[,,tc])/(cl*rw)
    }
if(anima==TRUE)
    {
        dev.new()
	animaMeta2(paisag)
	grFim(paisag)
    }
dev.new()
F=pi/(pi+pe)
op = par(mar=c(5.5,5,4,2), las=1,mgp= c(3.2,1,0))
plot(1:tmax,c(f0,resultado),type="l",xlab="Time",ylab="Proportion of occupation", ylim=c(0,1),main="Propagulus rain",sub= paste(" cols=",cl," rows=",rw," f0=",f0," pi=",pi," pe=",pe),cex.lab=1.3, cex.main=1.4, cex.axis=1.2,lwd=2, cex.sub=1.1, col="blue")
abline(h=F,col=2,lwd=2,lty=2)
legend("topright", legend=("expected equilibrium"), lty=2, col="red", bty="n")
invisible(paisag)
}
#metaPop(tmax=100,cl=20,rw=20,f0=0.2,pe=0.2,pi=0.5)
##################################################
## Propagulus seed rain with Internal Colonization
##################################################
##' @rdname metaPop 
metaCi <-function(cl,rw,f0,ci,pe, tmax, anima=TRUE)
{
     if( pe>1 | pe<0)
    {
        stop("probabilities (pe) should be a number between 0 and 1")
    }
     if(ci>1 | ci<0)
     {
         stop("coefficient of colonization (ci) represents the maximum probability of colonization (when f=1) and should be a number between 0 and 1")
     }
paisag=array(0,dim=c(rw,cl,tmax))
nmanchas=cl*rw
paisag[,,1]=matrix(sample(c(rep(1,f0*nmanchas), rep(0,round((1-f0)*nmanchas)))),ncol=cl)
resultado=numeric()
	for(tc in 2:tmax)
	{
        pi=ci* (sum(paisag[,,tc-1])/(cl*rw))
        if(pi>1)
        {
            pi=1
        }
	paisag[,,tc][paisag[,,(tc-1)]==1]<-sample(c(0,1),sum(paisag[,,(tc-1)]), replace=TRUE,prob=c(pe,1-pe))
	paisag[,,tc][paisag[,,(tc-1)]==0]<-sample(c(0,1),cl*rw-sum(paisag[,,(tc-1)]), replace=TRUE,prob=c(1-pi,pi))
   resultado[tc-1]=sum(paisag[,,tc])/nmanchas
        }
if(anima==TRUE)
    {
        dev.new()
        animaMeta2(paisag)
        grFim(paisag)
    }
dev.new()
F=1-(pe/ci)
if(F>1){F=1}
if(F<0){F=0}
op = par(mar=c(5.5,5,4,2), las=1,mgp= c(3.2,1,0))
plot(1:tmax,c(f0,resultado),type="l",xlab="Time",ylab="Proportion of occupation",ylim=c(0,1),main=paste("Propagulus Rain and Internal Colonization"),sub=paste(" cols=",cl," rows=",rw," f0=",f0," ci=",ci," pe=",pe),cex.lab=1.3, cex.main=1.4, cex.axis=1.2,lwd=2, cex.sub=1.1, col="blue")
abline(h=F,col=2,lwd=2,lty=2)
legend("topright", legend=(c("population trajectory","expected equilibrium")), lty=1:2, col=c("blue","red"), bty="n")
invisible(paisag)
}
#metaCi(tmax=100,cl=10,rw=10,f0=.1,ci=1,pe=0.5)
##################################################
## Propagulus Seed Rain with Rescue EFfect
##################################################
##' @rdname metaPop 
metaEr <-function(cl,rw,f0,pi,ce, tmax, anima=TRUE)
{
     if( pi>1 | pi<0)
    {
        stop("probabilities (pi) should be a number between 0 and 1")
    }
     if(ce>1 | ce<0)
     {
         stop("coefficient of extinction (ce) represents the maximum probability of extinction (when f=0) and should be a number between 0 and 1")
     }
nmanchas=cl*rw
paisag=array(0,dim=c(rw,cl,tmax))
paisag[,,1]=matrix(sample(c(1,0),nmanchas,prob=c(f0,1-f0), replace=TRUE),rw,cl)
resultado=numeric()
res=numeric()
	for(tc in 2:tmax)
	{
        pe=ce*(1-sum(paisag[,,tc-1])/nmanchas)
        if(pe>1)
        {
            pe=1
        }
	paisag[,,tc][paisag[,,(tc-1)]==1]<-sample(c(0,1),sum(paisag[,,(tc-1)]), replace=TRUE, prob=c(pe,1-pe))
	paisag[,,tc][paisag[,,(tc-1)]==0]<-sample(c(0,1),cl*rw-sum(paisag[,,(tc-1)]), replace=TRUE, prob=c(1-pi,pi))
	resultado[tc-1]=sum(paisag[,,tc])/nmanchas
	res[tc-1]=pe
    }
if(anima==TRUE)
    {
        dev.new()
        animaMeta2(paisag)
        grFim(paisag)
    }
dev.new()
F=pi/ce
if(F>1){F=1}
pe.eq=ce-pi
if(pe.eq<0){pe.eq=0}
op = par(mar=c(5.5,5,4,2), las=1,mgp= c(3.2,1,0))
plot(1:tmax,c(f0,resultado),type="l",xlab="Time",ylab="Proportion/Probability", ylim=c(0,1),main=paste("Propagulus Rain and Rescue Effect"),sub=paste("cols=",cl," rows=",rw," f0=",f0," pi=",pi," e=",ce), cex.lab=1.3, cex.main=1.4, cex.axis=1.2,lwd=2, cex.sub=1.1) 

abline(h=F,col=2,lwd=2,lty=2) # equilibrio F
points(1:tmax,c(ce*(1-f0),res),type='l',lwd=2,col="blue") # pe observado
abline(h=pe.eq,col="green",lwd=2,lty=2) # pe equilibrio
ymin=min(resultado[(length(resultado)/2):(length(resultado))])
legend(x=length(resultado)/2,y=ymin, legend=c("Proportion of occupancy (f)",  expression("Equilibrium "*hat(f)), "Extintion probability (pe)", "pe equilibrium"), lty=c(1,2,1,2), col=c("black","red","blue", "green"), bty="n")
invisible(paisag)
}
#metaEr(20,20,0.25,0.1,0.1,100)
##################################################
## Internal Colonization and Rescue Effect
##################################################
##' @rdname metaPop 
metaCiEr <-function(cl,rw,f0,ci,ce, tmax, anima=TRUE)
{
     if(ci>1 | ci<0)
     {
         stop("coefficient of colonization (ci) represents the maximum probability of colonization (when f=1) and should be a number between 0 and 1")
     }
     if(ce>1 | ce<0)
     {
         stop("coefficient of extinction (ce) represents the maximum probability of extinction (when f=0) and should be a number between 0 and 1")
     }
nmanchas=cl*rw
paisag=array(0,dim=c(rw,cl,tmax))
paisag[,,1]=sample(c(rep(0,round(nmanchas-f0*nmanchas)),rep(1,round(f0*nmanchas))))
resultado=numeric()
rese=numeric()
resi=numeric()
	for(tc in 2:tmax)
	{
	pe=ce*(1-(sum(paisag[,,tc-1])/nmanchas))
        if(pe>1)
        {
            pe=1
        }
	pi=ci*sum(paisag[,,tc-1])/nmanchas
        if(pi>1)
        {
            pi=1
        }
	paisag[,,tc][paisag[,,(tc-1)]==1]<-sample(c(0,1),sum(paisag[,,tc-1]),replace=TRUE,prob=c(pe,1-pe))
	paisag[,,tc][paisag[,,(tc-1)]==0]<-sample(c(0,1),nmanchas-sum(paisag[,,tc-1]),replace=TRUE,prob=c(1-pi,pi))
	resultado[tc-1]=sum(paisag[,,tc])/nmanchas
	rese[tc-1]=pe
	resi[tc-1]=pi
	}
if(anima)
    {
        dev.new()
        animaMeta2(paisag)
        grFim(paisag)
    }
dev.new()
op= par(las=1)
plot(1:tmax,c(f0,resultado),type="l",xlab="Time",ylab="Occupancy proportion", ylim=c(0,1),main=paste("Internal Colonization and Rescue Effect\n cols=",cl," rows=",rw," f0=",f0," ci=",ci, "ce=",ce),font.lab=2,lwd=2, cex.axis=1.2, cex.lab=1.2, cex.main=1.2)
abline(h=0,lty=2)
points(1:tmax,c(ce*(1-f0),rese),type='l',lwd=2,col=4,lty=3)
points(1:tmax,c(ci*f0,resi),type='l',lwd=2,col=6,lty=3)
legend("topright", legend=c("patch occupancy", "colonization", "extinction"), lty=c(1,3,3), col=c(1,6,4), bty="n")
invisible(paisag)
}
#############################END###############################################
