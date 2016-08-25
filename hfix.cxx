{
TFile *of=new TFile("analyresul/1e.root");
TTree *h11=(TTree*)of->Get("h11");
TFile *nf=new TFile("analyresul/1e1.root","recreate");
TTree *h10=h11->CloneTree(0);
h10->CopyEntries(h11);
h10->SetName("h10");
nf->Write();
return;
}

.q

