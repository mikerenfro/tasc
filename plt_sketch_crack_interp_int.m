function  plt_sketch_crack_interp_int(result)

% define local variables with compact names
a = result.fea.a;
c = result.fea.c;
width = result.fea.width;
B = result.fea.B;
predict_test = result.predict_test;
eval_test = result.eval_test;

%%
%Calculate values to draw circls, phi angle and tear length
% -- Enter values
t = B;
two_w = width;
w = width;

if predict_test == 1 || eval_test == 1 ;
    phi_tear = result.tear_angle;
else
    phi_tear = 30.0; %set equal to 30 deg. for generic plot without test data
end

phi = phi_tear;

% -- Convert phi into radians
deg_phi = phi;
phi = (phi / 360) * (2 * pi);


% -- Calculate coordinates of point on ellipse
x_phi = c * cos(phi);
y_phi = a * sin(phi);


% -- Calculate slope of perpindicular line
m_perp = (c^2 * y_phi) / (a^2 * x_phi);


% -- Calculate x-intercept of perpindicular line
x_int = (c * cos(phi)) - (((a^2) * cos(phi)) / c);


%-- Calculate distance from point on ellipse to intercept
dist_front = sqrt(((x_phi - x_int)^2) + ((y_phi)^2));


% -- Calculate x of perpindicular line at specimen edge
x_hits_top_edge = x_phi + ((t - y_phi) / m_perp);
y_hits_side_edge = y_phi + (m_perp * ((two_w / 2) - x_phi));

if x_hits_top_edge > (two_w / 2)
    x_edge = (two_w / 2);
    y_edge = y_hits_side_edge;
else
    x_edge = x_hits_top_edge;
    y_edge = t;
end


% -- Calculate distance from point on ellipse to point on edge
dist_back = sqrt(((x_edge - x_phi)^2) + ((y_edge - y_phi)^2));


% -- Calculate total distance along perpindicular line
dist_total = dist_front + dist_back;



x_circle = [-a:0.001:a];
for k = 1:length(x_circle) 
    y_circle(k) = sqrt((a^2)- (x_circle(k)^2)); 
end

x_on_circ = a * cos(phi);
y_on_circ = y_phi;

x_perp = [x_int:0.025:(x_edge+0.25)];
for k = 1:length(x_perp)
    y_perp(k) = y_phi + ((c^2 * y_phi)/(a^2 * x_phi) * (x_perp(k) - x_phi));   
end

%calculate length of r_phi_a plus r_phi_b (hyp)
H = ((x_int-x_edge)^2+y_edge^2)^0.5;


% -- Set up data for plotting


x_ellipse = [-c:0.001:c*1.00];
for k = 1:length(x_ellipse) 
    y_ellipse(k) = sqrt((a^2)*(1 - ((x_ellipse(k)^2) / (c^2)))); 
end


% -- Plot everything
%specimen_crack_sketch_compare = figure( 'Name','Specimen_Crack_Sketch_Compare',...
%                        'NumberTitle','off','color', 'w');
plot(x_circle,y_circle,'k:');
hold on
xlabel(result.length_str);
ylabel(result.length_str);
r = rectangle('position',[-w/2,0,w,t], 'Linewidth', 2, 'Linestyle', '-');
%plot(x_ellipse,y_ellipse,'r-', 'LineWidth', 1.5);

axis equal
 
            grid off
            h = area(x_ellipse,y_ellipse);
            set(h,'FaceColor',[.7 .7 .7]);
%%%
plot(x_circle,y_circle,'k:');
plot(x_on_circ,y_on_circ,'k*');
plot([0 x_on_circ],[0 y_on_circ],'k:');
plot([x_on_circ x_phi],[y_on_circ y_phi],'k:');
plot(x_phi,y_phi,'k*');
%plot(x_edge,y_edge,'g*');
%plot(x_int,0,'g*');
%%%%%%
xlim([-w/2*1.1 w/2*1.1]);
 
hold off
%drawnow;

   %print figure to emf file and save fig file    
%     filename = strcat(FilePrefix, '_sketch_crack');
%     print_file = strcat(pathname, '\', filename);
%     print(gcf,'-dmeta','-r300',print_file);
%     FigFile = strcat(print_file, '.fig');
%     saveas(gcf, FigFile);