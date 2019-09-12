function RDKsim
% Call RDKsim
% Simulates a RDK and estimates the density of the dots over a desired number of frames

% TO DO LIST
% Still one problem is the high density of dots at very low/high value of x
% Implement polar coordinate
% Organise script to have a certain percentage of dots with a coherent motion

ppd =  53; % Pixel per degree on a 39 cm wide screen seen at a 60 cm distance
%ppd =  40;
fps=60; % Frame per seconds on a "normal" screen

nframes = 60000 % number of animation frames in loop
report = ceil(nframes/10); % report the iteration number

MatrixSize=800; 
r=MatrixSize/2; % Radius of the RDK

dot_w       = 0.2;  % width of dot (deg)
s = dot_w * ppd; % dot size (pixels)

DotDensity=0.1; % Relative to the number of pixel in the disc surface of the RDK
nDots=ceil(pi*r^2/(2*pi*(s/2)^2)*DotDensity) % Number of dots : surface of the RDK disc / surface of one dot * density of dots


dot_speed   = 3; % Maximum dot speed en degree
pfs = dot_speed * ppd / fps; % Maximum dot speed en pixels
MinSpeed = 5; % how to implement it ?

f_kill = 0.2; % fraction of dots to kill each frame (limited lifetime)

% Initialise the different matrixes
r_dots=zeros(nDots,1);
xy=zeros(nDots,5); % Dot positions and speed matrix : colunm 1 to 5 gives rexpectively x position, y position, x speed, y speed, and distance of the point the RDK center

B=zeros(MatrixSize,MatrixSize); % Matrix to record positon of the dots at each frame

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%The following lines are a so-far-failed attempt to use polar coordinates
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    %t = 2*pi*rand(nDots,1) ; % theta polar coordinate
    %cs = [cos(t), sin(t)] ;
    %xy(:,5) = r*randn(nDots,1) ; % r polar coordinate
    %xy(:,1:2) = [xy(:,5) xy(:,5)] .* cs ; % dot positions in Cartesian coordinates (pixels from center)

    %dt = 2*pi*rand(nDots,1) ; % motion direction (in or out) for each dot
    %dR = r*randn(nDots,1) ; % change in radius per frame (pixels)
    %xy(:,3:4) = [(-xy(:,5)*sin(t)*dt+cos(t)*dR) (xy(:,5)*cos(t)*dt+sin(t)*dR)] ; % change in x and y per frame (pixels)
    
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

xy(:,1) = ceil((MatrixSize-2)*(rand(nDots,1))); % Gives random position to the dots in x. The "-2" in (MatrixSize-2) is there to reduces a too high density in the high end of x
xy(:,2) = round(r - ((r^2 - (r-xy(:,1)).^2) .^0.5) + 2*rand(nDots,1).*( r^2 - (r-xy(:,1)).^2) .^0.5); % Gives a random position in y as a function of x and r

xy(:,3:4) = round(rand(nDots,2) * 2*pfs-pfs); % Gives a "normal" random horizontal and vertical speed and multiplies it by the maximum dot speed en pixels 

for i = 1:nframes;	
	if mod(i, report)==0 % To know how far in the loop we are
		i			
	end		

	xy(:,1:2) = xy(:,1:2) + xy(:,3:4); % Move the dots
	%xy(:,5) =  xy(:,5)+dR %

	for i=1:nDots;
		xy(i,5) = (xy(i,1)-r)^2 + (xy(i,2)-r)^2; % calculate distance from matrix center for each dot
	end

	%r_out  = find(xy(:,5) > r | rand(nDots,1) < f_kill); % Finds if there is dots to reposition
	
	r_out  = find(xy(:,5) > (r^2) | rand(nDots,1) < f_kill); % Finds if there is dots to reposition
	n_out=length(r_out); % Number of dots to reposition

	if n_out;	
		xy(r_out,1) = ceil((MatrixSize-2)*(rand(n_out,1))); % Gives new x value to these dots
		xy(r_out,2) = round(r - ((r^2 - (r-xy(r_out,1)).^2) .^0.5) + 2*rand(n_out,1).*( r^2 - (r-xy(r_out,1)).^2) .^0.5); % Gives new y value to these dots

		xy(r_out,3:4) = round(rand(n_out,2) * 2*pfs-pfs); % Gives new velocities direction value to these dots
		
		%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		%t = 2*pi*rand(r_out,1); % theta polar coordinate
		%cs = [cos(t), sin(t)];
		%xy(r_out,5) = r*randn(r_out,1); % r polar coordinate
		%xy(r_out,1:2) = [xy(r_out,5) xy(r_out,5)] .* cs; % dot positions in Cartesian coordinates (pixels from center)
		
		%dt = 2*pi*rand(r_out,1) ; % motion direction (in or out) for each dot
		%dR = r*randn(r_out,1) ; % change in radius per frame (pixels)
		%xy(r_out,3:4) = [(-xy(r_out,5)*sin(t)*dt+cos(t)*dR) (xy(r_out,5)*cos(t)*dt+sin(t)*dR)] ; % change in x and y per frame (pixels)
		
		%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
	end	
	
	for i=1:nDots % Increments of 1 all the position of the matrix with a dot 
		if xy(i,2)<=0 | xy(i,1)<=0 % Don't know why this is there but it does not wor without
		else			
		B(xy(i,2),xy(i,1))=B(xy(i,2),xy(i,1))+1;
		end
	end	
end

subplot (211)
[X Y]=meshgrid(1:MatrixSize, 1:MatrixSize);
mesh (X, Y, B)

subplot (212)
imagesc(B)
axis('equal')
