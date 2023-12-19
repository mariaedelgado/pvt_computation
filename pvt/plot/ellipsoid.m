function h = ellipsoid(mx,Px,color)
% Author: Hakim Cherfi
% Returns ellipsoid containing 95% of samples of 2D Gaussian random variable 
% of mean mx and covariance Px
%  color : 'b' or 'g' or ...

k = 2.447^2; %excursion(k=alpha^2, excursion=alpha*sqrt(eigen value))

%table excursion/confidence interval
%sqrt(k)=1:39.4% , sqrt(k)=2:86.5% , sqrt(k)=2.447:95% , sqrt(k)=3:98.9%

Px = (Px+Px')/2; %to make covariance matrix symmetric
[V,D]=eig(Px); %V : vecteurs, D : matrice diagonale vp
t=0:0.1:2*pi+0.1; %+0.1 to go over 2*pi
xx(1,:)=sqrt(k*D(1,1))*cos(t);
xx(2,:)=sqrt(k*D(2,2))*sin(t);
X=zeros(size(xx));
for i=1:length(xx)
    X(:,i)=V*xx(:,i)+mx; %vectorial way
end
%h = patch(X(1,:),X(2,:),color,'edgecolor','none','facealpha',.2); %polygone (voronoi), no edge, facealpha = parametre transparence
h = patch(X(1,:),X(2,:),"w",'edgecolor',color,'facealpha',.2); %polygone (voronoi), no edge, facealpha = parametre transparence

end