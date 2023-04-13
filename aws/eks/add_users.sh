#Set to 1 or higher to see more info on intermediate steps
#export ANSIBLE_VERBOSITY=5

ansible-playbook add_users.yml --extra-vars "@eks_vars.yml" --extra-vars "@my_override_vars.yml"
