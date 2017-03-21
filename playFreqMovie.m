function playFreqMovie(out)

%%
mask = out.mask;

out1 = calcFreqAmp(out,[2, 4]);
delta0 = out1.freqFiltBlur;
%%
out1 = calcFreqAmp(out,[4, 8]);
theta0 = out1.freqFiltBlur;
%%
out1 = calcFreqAmp(out,[8,15]);
alpha0 = out1.freqFiltBlur;
%%
out1 = calcFreqAmp(out,[15,30]);
beta0 = out1.freqFiltBlur;
%%
out1 = calcFreqAmp(out,[30,90]);
gamma0 = out1.freqFiltBlur;
%%
out1 = calcFreqAmp(out,[80,90]);
norm0 = out1.freqFiltBlur;

normFact = std(norm0,0,3);

delta = bsxfun(@times,delta0,mask);
theta = bsxfun(@times,theta0,mask);
alpha = bsxfun(@times,alpha0,mask);
beta = bsxfun(@times,beta0,mask);
gamma = bsxfun(@times,gamma0,mask);

delta2 = bsxfun(@rdivide,bsxfun(@minus,delta,normFact),normFact);
theta2 = bsxfun(@rdivide,bsxfun(@minus,theta,normFact),normFact);
alpha2 = bsxfun(@rdivide,bsxfun(@minus,alpha,normFact),normFact);
beta2 = bsxfun(@rdivide,bsxfun(@minus,beta,normFact),normFact);
gamma2 = bsxfun(@rdivide,bsxfun(@minus,gamma,normFact),normFact);

%%

hF = figure;
for X = 1:5:out.sZ-20
    if ishandle(hF)
        subplot(2,3,1), imagesc(delta2(:,:,X)), caxis([0 10]), title('delta'), axis off square
        subplot(2,3,2), imagesc(theta2(:,:,X)), caxis([0 10]), title('theta'), axis off square
        subplot(2,3,3), imagesc(alpha2(:,:,X)), caxis([0 10]), title('alpha'), axis off square
        subplot(2,3,4), imagesc(beta2(:,:,X)), caxis([5 10]), title('beta'), axis off square
        subplot(2,3,5), imagesc(gamma2(:,:,X)), caxis([15 25]), title('gamma'), axis off square
        subplot(2,3,6), imagesc(out.imgD(:,:,X)), caxis([0 8000]), title('base'), axis off square
        newLabel = [num2str(X*5) ' ms'];
        text('units','pixels','position',[10 5],'fontsize',15,'string',newLabel,'Color','w')
        pause(0.0001)
        
    else
        break
    end
end