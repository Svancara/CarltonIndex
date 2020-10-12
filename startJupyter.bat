# start bash
rem docker run -it --rm -p 8888:8888 -v e:\Projekty\c2_R\JupyterNotebookCarlton:/home/carlton --name=jupyter bob/bob-r-notebook:run bash 

# start jupyter
rem docker run -it --rm -p 8888:8888 -v e:\\Projekty\\c2_R\\JupyterNotebookCarlton:/home/jovyan/work --name=jupyter bob/bob-r-notebook:run bash  


docker run -it --rm -p 8888:8888 -v e:\\Projekty\\c2_R\\JupyterNotebookCarlton:/home/jovyan/work --name=jupyter bob/bob-r-notebook:run start-notebook.sh
  



