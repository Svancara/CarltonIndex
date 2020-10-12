Let's run jupyter docker container from Windows.


# Run wsl.exe somewhere
# In it, cd to this directory and run this file 
# docker run -it --rm -e PASSWORD=heslolv88  -p 8787:8787 -p 6311:6311 -v /mnt/e/Projekty/c2_R:/home/Projekty/c2_R --name=seetu bob/seetu2:run bash

# Run wsl.exe somewhere
# In it, cd to this directory and run this file 
# docker run -it --rm -e PASSWORD=heslolv88  -p 8787:8787 -p 6311:6311 -v /mnt/e/Projekty/c2_R:/home/Projekty/c2_R --name=seetu bob/seetu2:run bash

# docker run -it --rm jupyter/r-notebook -p 8787:8787 -p 6311:6311 -v /mnt/e/Projekty/c2_R/JupyterNotebookCarlton:/home/JupyterNotebookCarlton bash                                                 

# docker run -it --rm jupyter/r-notebook -p 8888:8888 -p 6311:6311 -v /mnt/e/Projekty/c2_R/JupyterNotebookCarlton:/home                                                 


# FUNGUJE
docker run -it --rm -p 8888:8888  bob/bob-r-notebook:run start-notebook.sh 


This does not work
docker run -it --rm -p 8888:8888 -v /mnt/e/Projekty/c2_R/JupyterNotebookCarlton:/home/carlton bob/bob-r-notebook:run start-notebook.sh