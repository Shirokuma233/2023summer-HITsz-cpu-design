#include<bits/stdc++.h>

using namespace std;

int main()
{
  ifstream fin("lab1.hex");
  ofstream fout("instruction.coe");
  fout<<"memory_initialization_radix = 16;"<<endl<<"memory_initialization_vector ="<<endl;
  vector<string> v;
  while(!fin.eof())
  {
    string s;
    fin>>s;
    s = s+",";
    if(s != ",") v.push_back(s);
  }

  for(int i=0;i<v.size();i++)
  {
    if(i == v.size()-1)
    {
      string str=v[i];
      str[str.size()-1]=';';
      fout<<str<<endl;
    }
    else fout<<v[i]<<endl;
  }
  return 0;
}